/*
 * Copyright 2023 BI X GmbH
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/services.dart';

import 'package:visualr_app/common/services/parse_service.dart';
import 'package:visualr_app/meta.dart';
import 'package:visualr_app/reading_speed/models/result.dart';
import 'package:visualr_app/reading_speed/models/step.dart';
import 'package:visualr_app/reading_speed/models/summary.dart';
import 'package:visualr_app/reading_speed/services/detector/pair_detector.dart';
import 'package:visualr_app/reading_speed/services/detector/single_detector.dart';
import 'package:visualr_app/reading_speed/services/detector/trigger_detector.dart';
import 'package:visualr_app/reading_speed/services/detector/triplet_detector.dart';
import 'package:visualr_app/reading_speed/services/speech_recognition_service.dart';

const numberOfWords = 97;
const Map<String, String> triggerWordsPerLocale = {
  "de": "Rathaus Rechnung Tomate",
  "en": "microphone apple train",
};

class ReadingSpeedTestSequenceManager {
  String locale;
  List<String> words = [];
  String triggerWords = "";
  bool hasError = false;

  final List<ReadingSpeedTestStep> _readingSpeedTestSteps = [];

  final _speechRecognitionService = SpeechRecognitionService();

  ReadingSpeedTestStep get current =>
      steps[0].result == null ? steps[0] : steps[1];

  List<ReadingSpeedTestStep> get steps => _readingSpeedTestSteps;

  ReadingSpeedTestSequenceManager({required this.locale}) {
    triggerWords = triggerWordsPerLocale[locale]!;
  }

  static Future<ReadingSpeedTestSequenceManager> startManager(
    String locale,
  ) async {
    final manager = ReadingSpeedTestSequenceManager(locale: locale);
    return manager;
  }

  Future<ReadingSpeedTestStep> createTestEvent(EyeEnum eye) async {
    if (words.isEmpty) {
      words = await getWords(locale);
    }
    final ReadingSpeedTestStep step = ReadingSpeedTestStep(
      eye: eye,
      words: addTriggerWords(words),
      createdAt: DateTime.now(),
    );
    _readingSpeedTestSteps.add(step);
    return step;
  }

  Future<List<String>> getWords(String locale) async {
    final String textFile =
        await rootBundle.loadString('assets/reading/b1_list_$locale.txt');
    final List<String> words = textFile.split('\n');
    words.shuffle();
    return words.sublist(0, numberOfWords);
  }

  String addTriggerWords(List<String> words) {
    words.shuffle();
    return '${words.join(" ")} $triggerWords';
  }

  double calculateWordsPerMinute(Duration duration) {
    return 100 / duration.inMilliseconds * 60000;
  }

  Future<ReadingSpeedSummary?> processWhisperResult(
    ReadingSpeedWhisperResult whisperResult,
  ) async {
    if (whisperResult.type == '@error') {
      return Future.error(
        Exception("Whisper could not process the audio clip."),
      );
    }
    try {
      current.result = await createResultFromWhisper(whisperResult, current);
      if (steps.where((step) => step.result != null).length == 2) {
        final ReadingSpeedTestStep leftEyeStep = steps.firstWhere(
          (step) => step.eye == EyeEnum.left,
        );
        final ReadingSpeedTestStep rightEyeStep = steps.firstWhere(
          (step) => step.eye == EyeEnum.right,
        );
        return ReadingSpeedSummary(
          left: ReadingSpeedEyeSummary(
            cer: leftEyeStep.result!.characterErrorRate,
            endTime: leftEyeStep.result!.endTime,
            startTime: leftEyeStep.result!.startTime,
            wordsPerMinute: calculateWordsPerMinute(
              leftEyeStep.result!.endTime - leftEyeStep.result!.startTime,
            ),
            wer: leftEyeStep.result!.wordErrorRate,
          ),
          right: ReadingSpeedEyeSummary(
            cer: rightEyeStep.result!.characterErrorRate,
            endTime: rightEyeStep.result!.endTime,
            startTime: rightEyeStep.result!.startTime,
            wordsPerMinute: calculateWordsPerMinute(
              rightEyeStep.result!.endTime - rightEyeStep.result!.startTime,
            ),
            wer: rightEyeStep.result!.wordErrorRate,
          ),
        );
      }
    } catch (e) {
      return Future.error(e);
    }
    return null;
  }

  Future<ReadingSpeedResult> createResultFromWhisper(
    ReadingSpeedWhisperResult whisperResult,
    ReadingSpeedTestStep step,
  ) async {
    try {
      if (whisperResult.segments == null) {
        return Future.error(
          Exception("Whisper was not able to create any Segments."),
        );
      }
      final TriggerDetectorResult result = await tryDetectTrigger(
        whisperResult: whisperResult,
        triggerWords: triggerWords,
      );
      return ReadingSpeedResult(
        words: step.words,
        startTime: ParseService.duration(result.startTime),
        endTime: ParseService.duration(result.endTime),
        wordErrorRate: _speechRecognitionService.wordErrorRate(
          step.words,
          result.transcribedText,
        ),
        characterErrorRate: _speechRecognitionService.characterErrorRate(
          step.words,
          result.transcribedText,
        ),
        eye: step.eye,
      );
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<TriggerDetectorResult> tryDetectTrigger({
    required ReadingSpeedWhisperResult whisperResult,
    required String triggerWords,
    double threshold = 0.2,
  }) async {
    TriggerDetectorResult? result = tryDetectTriplet(
      whisperResult: whisperResult,
      triggerWords: triggerWords,
      threshold: threshold,
    );
    if (result == null) {
      result = tryDetectPair(
        whisperResult: whisperResult,
        triggerWords: triggerWords,
        threshold: threshold,
      );
      if (result == null) {
        result = tryDetectSingle(
          whisperResult: whisperResult,
          triggerWords: triggerWords,
          threshold: threshold,
        );
        if (result == null) {
          return Future.error(
            Exception(
              "Trigger sequence could not be identified in transcript.",
            ),
          );
        }
      }
    }
    return result;
  }

  TriggerDetectorResult? tryDetectTriplet({
    required ReadingSpeedWhisperResult whisperResult,
    required String triggerWords,
    double threshold = 0.2,
  }) {
    final TripletDetector tripletDetector = TripletDetector(
      triggerWords: triggerWords,
      whisperResult: whisperResult,
    );
    return tripletDetector.detectTrigger(threshold);
  }

  TriggerDetectorResult? tryDetectPair({
    required ReadingSpeedWhisperResult whisperResult,
    required String triggerWords,
    double threshold = 0.2,
  }) {
    final PairDetector pairDetector = PairDetector(
      triggerWords: triggerWords,
      whisperResult: whisperResult,
    );
    return pairDetector.detectTrigger(threshold);
  }

  TriggerDetectorResult? tryDetectSingle({
    required ReadingSpeedWhisperResult whisperResult,
    required String triggerWords,
    double threshold = 0.2,
  }) {
    final SingleDetector singleDetector = SingleDetector(
      triggerWords: triggerWords,
      whisperResult: whisperResult,
    );
    return singleDetector.detectTrigger(threshold);
  }
}
