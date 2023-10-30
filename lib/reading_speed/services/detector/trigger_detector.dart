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

import 'package:visualr_app/reading_speed/models/step.dart';
import 'package:visualr_app/reading_speed/services/speech_recognition_service.dart';

abstract class TriggerDetector {
  final ReadingSpeedWhisperResult whisperResult;
  final String triggerWords;
  final SpeechRecognitionService speechRecognitionService =
      SpeechRecognitionService();

  TriggerDetector({required this.triggerWords, required this.whisperResult});

  /// Detects if the trigger words can be found in the transcript.
  ///
  /// Returns `TriggerDetectorResult` if a segment was found that has a
  /// character error rate smaller or equal than `threshold`.
  ///
  /// Returns `null` if any error appears during the processing of the
  /// transcript or the character error rate of every segment created is greater
  /// than `threshold`.
  TriggerDetectorResult? detectTrigger(double threshold);

  /// Converts `textList` into a list of `DetectedTrigger`.
  /// The amount of words used as `trigger` in `DetectedTrigger` depends on the
  /// implementation of the function, but should be three, two or one.
  List<DetectedTrigger> createSegments(List<String> textList);

  /// Checks all `segments` and possible combinations of adjacent `segments` for
  /// `recognizedTrigger` and returns the time at which the `recognizedTrigger`
  /// was recognized.
  ///
  /// Returns `null` if any error occurs or `recognizedTrigger` could not be
  /// found.
  String? calculateEndTime(
    List<WhisperSegment> segments,
    String recognizedTrigger,
  );

  /// Cleans up `input` by removing any unwanted characters and converting
  /// all characters left to lower case.
  String cleanUpTranscript(String input) {
    return input
        .trim()
        .replaceAll(",", "")
        .replaceAll(".", "")
        .replaceAll("-", " ")
        .toLowerCase();
  }

  /// Loops over every `DetectedTrigger` in `segments` and return the
  /// `DetectedTrigger` with the lowest character error rate.
  DetectedTrigger getSegmentWithMinimumCer(List<DetectedTrigger> segments) {
    return segments
        .reduce((current, next) => current.cer < next.cer ? current : next);
  }
}

class DetectedTrigger {
  final String trigger;
  final double cer;

  DetectedTrigger({required this.trigger, required this.cer});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DetectedTrigger &&
        other.trigger == trigger &&
        other.cer == cer;
  }

  @override
  int get hashCode => Object.hash(trigger, cer);
}

class TriggerDetectorResult {
  final String startTime;
  final String endTime;
  final String transcribedText;
  TriggerDetectorResult({
    required this.startTime,
    required this.endTime,
    required this.transcribedText,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TriggerDetectorResult &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.transcribedText == transcribedText;
  }

  @override
  int get hashCode => Object.hash(startTime, endTime, transcribedText);
}
