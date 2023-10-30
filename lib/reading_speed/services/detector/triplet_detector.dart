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
import 'package:visualr_app/reading_speed/services/detector/trigger_detector.dart';

class TripletDetector extends TriggerDetector {
  TripletDetector({required super.triggerWords, required super.whisperResult});

  @override
  TriggerDetectorResult? detectTrigger(double threshold) {
    final cleanTranscript = cleanUpTranscript(whisperResult.text);
    final List<String> textList = cleanTranscript.split(" ");
    final List<DetectedTrigger> triplets = createSegments(textList);
    if (triplets.isEmpty) return null;
    final DetectedTrigger minCerTriplet = getSegmentWithMinimumCer(triplets);
    if (minCerTriplet.cer > threshold) return null;
    final String? endTime = calculateEndTime(
      whisperResult.segments!,
      minCerTriplet.trigger,
    );
    if (endTime == null) return null;
    final String transcribedText = cleanTranscript.substring(
      0,
      cleanTranscript.indexOf(minCerTriplet.trigger) +
          minCerTriplet.trigger.length,
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
    for (int i = 0; i < textList.length - 2; i++) {
      final triplet = cleanUpTranscript(
        textList.sublist(i, i + 3).join(" ").trim(),
      );
      final cer = speechRecognitionService.characterErrorRate(
        triggerWords.toLowerCase(),
        triplet,
      );
      segments.add(
        DetectedTrigger(
          trigger: triplet,
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
    if (segments.length < 3) return null;
    endTime = checkForTriggerInThreeSegments(segments, recognizedTrigger);
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
              .contains(recognizedTriggerWords.sublist(1).join(" "))) {
        return segments[i + 1].t0;
      }
      if (cleanUpTranscript(segments[i].text)
              .contains(recognizedTriggerWords.sublist(0, 2).join(" ")) &&
          cleanUpTranscript(segments[i + 1].text)
              .contains(recognizedTriggerWords[2])) {
        return segments[i + 1].t0;
      }
    }
    return null;
  }

  /// Detects if the `recognizedTrigger` is in three adjacent segments.
  ///
  /// Takes in all `segments` and returns `t0` of the segment that
  /// contains the last word of the `recognizedTrigger` if three adjacent
  /// segments contain the complete `recognizedTrigger`.
  /// Returns `null` if the `recognizedTrigger` could not be found in
  /// three adjacent segments.
  String? checkForTriggerInThreeSegments(
    List<WhisperSegment> segments,
    String recognizedTrigger,
  ) {
    final List<String> recognizedTriggerWords = recognizedTrigger.split(" ");
    for (int i = 0; i < segments.length - 2; i++) {
      if (cleanUpTranscript(segments[i].text)
              .contains(recognizedTriggerWords[0]) &&
          cleanUpTranscript(segments[i + 1].text)
              .contains(recognizedTriggerWords[1]) &&
          cleanUpTranscript(segments[i + 2].text)
              .contains(recognizedTriggerWords[2])) {
        return segments[i + 2].t0;
      }
    }
    return null;
  }
}
