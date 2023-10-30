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

import 'package:flutter_test/flutter_test.dart';
import 'package:visualr_app/reading_speed/models/step.dart';
import 'package:visualr_app/reading_speed/services/detector/pair_detector.dart';
import 'package:visualr_app/reading_speed/services/detector/single_detector.dart';
import 'package:visualr_app/reading_speed/services/detector/trigger_detector.dart';
import 'package:visualr_app/reading_speed/services/detector/triplet_detector.dart';

void main() {
  group("TripletDetector", () {
    const String triggerWords = "microphone apple train";
    const String dirtyTranscript = "test, microphone-apple train.";
    const String cleanTranscript = "test microphone apple train";
    final List<DetectedTrigger> triplets = [
      DetectedTrigger(trigger: "test microphone apple", cer: 0.5),
      DetectedTrigger(trigger: "microphone apple train", cer: 0.0),
    ];
    final ReadingSpeedWhisperResult whisperResultSuccess =
        ReadingSpeedWhisperResult(
      type: "transcribe",
      segments: [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "test",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:07.500",
          text: "microphone apple train",
        ),
      ],
      text: dirtyTranscript,
      sentText: "sample text microphone apple train",
    );
    final ReadingSpeedWhisperResult whisperResultError =
        ReadingSpeedWhisperResult(
      type: "transcribe",
      segments: [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "test",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:07.500",
          text: "microphoneappletrain",
        ),
      ],
      text: "test end test",
      sentText: "sample text microphone apple train",
    );
    final TripletDetector tripletDetectorSuccess = TripletDetector(
      triggerWords: triggerWords,
      whisperResult: whisperResultSuccess,
    );
    final TripletDetector tripletDetectorError = TripletDetector(
      triggerWords: triggerWords,
      whisperResult: whisperResultError,
    );

    test("should cleanup transcript", () {
      expect(
        tripletDetectorSuccess.cleanUpTranscript(dirtyTranscript),
        cleanTranscript,
      );
    });
    test("should create segments", () {
      expect(
        tripletDetectorSuccess.createSegments(cleanTranscript.split(" ")),
        triplets,
      );
    });
    test("should get triplet with minimum CER", () {
      expect(
        tripletDetectorSuccess.getSegmentWithMinimumCer(triplets),
        DetectedTrigger(trigger: "microphone apple train", cer: 0.0),
      );
    });
    test("should detect trigger in one segment", () {
      final List<WhisperSegment> segments = [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "microphone apple train",
        ),
      ];
      expect(
        tripletDetectorSuccess.checkForTriggerInOneSegment(
          segments,
          triggerWords,
        ),
        "0:03.000",
      );
    });
    test("should return null if triplet not in one segment", () {
      final List<WhisperSegment> segments = [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "microphone apple",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:05.000",
          text: "train",
        ),
      ];
      expect(
        tripletDetectorSuccess.checkForTriggerInOneSegment(
          segments,
          triggerWords,
        ),
        null,
      );
    });
    test("should detect trigger in two segments", () {
      final List<WhisperSegment> segmentsLeftJoin = [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "microphone apple",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:05.000",
          text: "train",
        ),
      ];
      final List<WhisperSegment> segmentsRightJoin = [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "microphone",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:05.000",
          text: "apple train",
        ),
      ];
      expect(
        tripletDetectorSuccess.checkForTriggerInTwoSegments(
          segmentsLeftJoin,
          triggerWords,
        ),
        "0:03.500",
      );
      expect(
        tripletDetectorSuccess.checkForTriggerInTwoSegments(
          segmentsRightJoin,
          triggerWords,
        ),
        "0:03.500",
      );
    });
    test("should return null if triplet not in two segments", () {
      final List<WhisperSegment> segments = [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "microphone",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:05.000",
          text: "apple",
        ),
        WhisperSegment(
          t0: "0:05.500",
          t1: "0:07.000",
          text: "train",
        ),
      ];
      expect(
        tripletDetectorSuccess.checkForTriggerInTwoSegments(
          segments,
          triggerWords,
        ),
        null,
      );
    });
    test("should detect trigger in three segments", () {
      final List<WhisperSegment> segments = [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "microphone",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:05.000",
          text: "apple",
        ),
        WhisperSegment(
          t0: "0:05.500",
          t1: "0:07.000",
          text: "train",
        ),
      ];
      expect(
        tripletDetectorSuccess.checkForTriggerInThreeSegments(
          segments,
          triggerWords,
        ),
        "0:05.500",
      );
    });
    test("should return result object if trigger words were detected", () {
      expect(
        tripletDetectorSuccess.detectTrigger(0.2),
        TriggerDetectorResult(
          startTime: "0:00.000",
          endTime: "0:07.500",
          transcribedText: "test microphone apple train",
        ),
      );
    });
    test("should return null if trigger words were not detected", () {
      expect(
        tripletDetectorError.detectTrigger(0.2),
        null,
      );
    });
  });

  group("PairDetector", () {
    const String triggerWords = "microphone apple train";
    const String detectedTrigger = "microphoneapple train";
    final List<DetectedTrigger> pairs = [
      DetectedTrigger(trigger: "test microphoneapple", cer: 0.5238095238095238),
      DetectedTrigger(trigger: "microphoneapple train", cer: 0.0),
    ];
    final ReadingSpeedWhisperResult whisperResultSuccess =
        ReadingSpeedWhisperResult(
      type: "transcribe",
      segments: [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "test microphoneapple",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:04.500",
          text: "train",
        ),
      ],
      text: "test, microphoneapple train.",
      sentText: "sample text microphone apple train",
    );
    final ReadingSpeedWhisperResult whisperResultError =
        ReadingSpeedWhisperResult(
      type: "transcribe",
      segments: [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "test",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:07.500",
          text: "microphoneappletrain",
        ),
      ],
      text: "microphoneappletrain",
      sentText: "sample text microphone apple train",
    );
    final PairDetector pairDetectorSuccess = PairDetector(
      triggerWords: triggerWords,
      whisperResult: whisperResultSuccess,
    );
    final PairDetector pairDetectorError = PairDetector(
      triggerWords: triggerWords,
      whisperResult: whisperResultError,
    );
    test("should create segments", () {
      expect(
        pairDetectorSuccess
            .createSegments("test microphoneapple train".split(" ")),
        pairs,
      );
    });
    test("should get pair with minimum CER", () {
      expect(
        pairDetectorSuccess.getSegmentWithMinimumCer(pairs),
        DetectedTrigger(trigger: "microphoneapple train", cer: 0.0),
      );
    });
    test("should detect trigger in one segment", () {
      final List<WhisperSegment> segments = [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "microphoneapple train",
        ),
      ];
      expect(
        pairDetectorSuccess.checkForTriggerInOneSegment(
          segments,
          detectedTrigger,
        ),
        "0:03.000",
      );
    });
    test("should return null if pair not in one segment", () {
      final List<WhisperSegment> segments = [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "microphoneapple",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:05.000",
          text: "train",
        ),
      ];
      expect(
        pairDetectorSuccess.checkForTriggerInOneSegment(
          segments,
          detectedTrigger,
        ),
        null,
      );
    });
    test("should detect trigger in two segments", () {
      final List<WhisperSegment> segments = [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "microphoneapple",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:05.000",
          text: "train",
        ),
      ];
      expect(
        pairDetectorSuccess.checkForTriggerInTwoSegments(
          segments,
          detectedTrigger,
        ),
        "0:03.500",
      );
    });
    test("should return result object if trigger words were detected", () {
      expect(
        pairDetectorSuccess.detectTrigger(0.2),
        TriggerDetectorResult(
          startTime: "0:00.000",
          endTime: "0:03.500",
          transcribedText: "test microphoneapple train",
        ),
      );
    });
    test("should return null if trigger words were not detected", () {
      expect(
        pairDetectorError.detectTrigger(0.2),
        null,
      );
    });
  });

  group("SingleDetector", () {
    const String triggerWords = "microphone apple train";
    const String detectedTrigger = "microphoneappletrain";
    final List<DetectedTrigger> singles = [
      DetectedTrigger(trigger: "test", cer: 0.9),
      DetectedTrigger(trigger: "microphoneappletrain", cer: 0.0),
    ];
    final ReadingSpeedWhisperResult whisperResultSuccess =
        ReadingSpeedWhisperResult(
      type: "transcribe",
      segments: [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "test",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:04.500",
          text: "microphoneappletrain",
        ),
      ],
      text: "test, microphoneappletrain.",
      sentText: "sample text microphone apple train",
    );
    final ReadingSpeedWhisperResult whisperResultError =
        ReadingSpeedWhisperResult(
      type: "transcribe",
      segments: [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "test",
        ),
        WhisperSegment(
          t0: "0:03.500",
          t1: "0:07.500",
          text: "end test",
        ),
      ],
      text: "test end test",
      sentText: "sample text microphone apple train",
    );
    final SingleDetector singleDetectorSuccess = SingleDetector(
      triggerWords: triggerWords,
      whisperResult: whisperResultSuccess,
    );
    final SingleDetector singleDetectorError = SingleDetector(
      triggerWords: triggerWords,
      whisperResult: whisperResultError,
    );
    test("should create segments", () {
      expect(
        singleDetectorSuccess
            .createSegments("test microphoneappletrain".split(" ")),
        singles,
      );
    });
    test("should get pair with minimum CER", () {
      expect(
        singleDetectorSuccess.getSegmentWithMinimumCer(singles),
        DetectedTrigger(trigger: "microphoneappletrain", cer: 0.0),
      );
    });
    test("should detect trigger in one segment", () {
      final List<WhisperSegment> segments = [
        WhisperSegment(
          t0: "0:00.000",
          t1: "0:03.000",
          text: "microphoneappletrain",
        ),
      ];
      expect(
        singleDetectorSuccess.checkForTriggerInOneSegment(
          segments,
          detectedTrigger,
        ),
        "0:03.000",
      );
    });
    test("should return result object if trigger words were detected", () {
      expect(
        singleDetectorSuccess.detectTrigger(0.2),
        TriggerDetectorResult(
          startTime: "0:00.000",
          endTime: "0:04.500",
          transcribedText: "test microphoneappletrain",
        ),
      );
    });
    test("should return null if trigger words were not detected", () {
      expect(
        singleDetectorError.detectTrigger(0.2),
        null,
      );
    });
  });
}
