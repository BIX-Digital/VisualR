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

class SingleDetector extends TriggerDetector {
  SingleDetector({required super.triggerWords, required super.whisperResult});

  @override
  TriggerDetectorResult? detectTrigger(double threshold) {
    final cleanTranscript = cleanUpTranscript(whisperResult.text);
    final List<String> textList = cleanTranscript.split(" ");
    final List<DetectedTrigger> singles = createSegments(textList);
    if (singles.isEmpty) return null;
    final DetectedTrigger minCerSingle = getSegmentWithMinimumCer(singles);
    if (minCerSingle.cer > threshold) return null;
    final String? endTime = calculateEndTime(
      whisperResult.segments!,
      minCerSingle.trigger,
    );
    if (endTime == null) return null;
    final String transcribedText = cleanTranscript.substring(
      0,
      cleanTranscript.indexOf(minCerSingle.trigger) +
          minCerSingle.trigger.length,
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
    for (int i = 0; i < textList.length; i++) {
      final single = cleanUpTranscript(
        textList.sublist(i, i + 1).join(" ").trim(),
      );
      final cer = speechRecognitionService.characterErrorRate(
        triggerWords.replaceAll(" ", "").toLowerCase(),
        single,
      );
      segments.add(
        DetectedTrigger(
          trigger: single,
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
    final String? endTime =
        checkForTriggerInOneSegment(segments, recognizedTrigger);
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
}
