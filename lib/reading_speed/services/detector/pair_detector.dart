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

import 'dart:math';

import 'package:visualr_app/reading_speed/models/step.dart';
import 'package:visualr_app/reading_speed/services/detector/trigger_detector.dart';

class PairDetector extends TriggerDetector {
  PairDetector({required super.triggerWords, required super.whisperResult});

  @override
  TriggerDetectorResult? detectTrigger(double threshold) {
    final cleanTranscript = cleanUpTranscript(whisperResult.text);
    final List<String> textList = cleanTranscript.split(" ");
    final List<DetectedTrigger> pairs = createSegments(textList);
    if (pairs.isEmpty) return null;
    final DetectedTrigger minCerPair = getSegmentWithMinimumCer(pairs);
    if (minCerPair.cer > threshold) return null;
    final String? endTime = calculateEndTime(
      whisperResult.segments!,
      minCerPair.trigger,
    );
    if (endTime == null) return null;
    final String transcribedText = cleanTranscript.substring(
      0,
      cleanTranscript.indexOf(minCerPair.trigger) + minCerPair.trigger.length,
    );
    return TriggerDetectorResult(
      startTime: whisperResult.segments![0].t0,
      endTime: endTime,
      transcribedText: transcribedText,
    );
  }

  @override
  List<DetectedTrigger> createSegments(List<String> textList) {
    final List<DetectedTrigger> segments = [];
    for (int i = 0; i < textList.length - 1; i++) {
      final pair = cleanUpTranscript(
        textList.sublist(i, i + 2).join(" ").trim(),
      );
      final String leftJoinedTrigger =
          triggerWords.replaceFirst(" ", "").toLowerCase();
      final String rightJoinedTrigger = triggerWords
          .replaceFirst(" ", "", triggerWords.lastIndexOf(" "))
          .toLowerCase();
      final cer = min(
        speechRecognitionService.characterErrorRate(
          leftJoinedTrigger,
          pair,
        ),
        speechRecognitionService.characterErrorRate(
          rightJoinedTrigger,
          pair,
        ),
      );
      segments.add(
        DetectedTrigger(
          trigger: pair,
          cer: cer,
        ),
      );
    }
    return segments;
  }

  @override
  String? calculateEndTime(
    List<WhisperSegment> segments,
    String recognizedTrigger,
  ) {
    String? endTime = checkForTriggerInOneSegment(segments, recognizedTrigger);
    if (endTime != null) return endTime;
    if (segments.length < 2) return null;
    endTime = checkForTriggerInTwoSegments(segments, recognizedTrigger);
    if (endTime != null) return endTime;
    return null;
  }

  /// Detects if the `recognizedTrigger` is in one segment.
  ///
  /// Takes in all `segments` and returns `t1` of the segment that
  /// contains the `recognizedTrigger`.
  /// Returns `null` if the `recognizedTrigger` could not be found
  /// in one segment.
  String? checkForTriggerInOneSegment(
    List<WhisperSegment> segments,
    String recognizedTrigger,
  ) {
    for (final WhisperSegment segment in segments) {
      if (cleanUpTranscript(segment.text).contains(recognizedTrigger)) {
        return segment.t1;
      }
    }
    return null;
  }

  /// Detects if the `recognizedTrigger` is in two adjacent segments.
  ///
  /// Takes in all `segments` and returns `t0` of the segment that
  /// contains the last word of the `recognizedTrigger` if two adjacent
  /// segments contain the complete `recognizedTrigger`.
  /// Returns `null` if the `recognizedTrigger` could not be found in
  /// two adjacent segments.
  String? checkForTriggerInTwoSegments(
    List<WhisperSegment> segments,
    String recognizedTrigger,
  ) {
    final List<String> recognizedTriggerWords = recognizedTrigger.split(" ");
    for (int i = 0; i < segments.length - 1; i++) {
      if (cleanUpTranscript(segments[i].text)
              .contains(recognizedTriggerWords[0]) &&
          cleanUpTranscript(segments[i + 1].text)
              .contains(recognizedTriggerWords[1])) {
        return segments[i + 1].t0;
      }
    }
    return null;
  }
}
