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

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visualr_app/distortion/models/binary_search.dart';
import 'package:visualr_app/distortion/models/line.dart';
import 'package:visualr_app/distortion/services/service.dart';

import '../../setup.dart';

void setTimeStamps(DistortionService service) {
  service.manager.current.createdAt = DateTime.now();
  service.manager.current.answerGivenAt = DateTime.now();
}

Future<void> sendUserAnswer({
  required DistortionService service,
  bool? answer,
}) async {
  service.incomingStream.add(answer);
  setTimeStamps(service);
  return Future.delayed(Duration.zero);
}

class BinarySearchIterator {
  String line;
  int iteration = 0;
  BinarySearchIterator({required this.line});

  Future<void> moveForward({required DistortionService service}) async {
    switch (line) {
      case "0_v_r":
        switch (iteration) {
          case 0:
            await sendUserAnswer(service: service, answer: false);
          case 1:
            await sendUserAnswer(service: service, answer: true);
          case 2:
            await sendUserAnswer(service: service, answer: false);
          case 3:
            await sendUserAnswer(service: service, answer: false);
          case 4:
            await sendUserAnswer(service: service, answer: true);
          case 5:
            await sendUserAnswer(service: service, answer: false);
          case 6:
            await sendUserAnswer(service: service, answer: true);
          case 7:
            await sendUserAnswer(service: service, answer: false);
          case 8:
            await sendUserAnswer(service: service, answer: true);
        }
      case "1_h_l":
        switch (iteration) {
          case 0:
            await sendUserAnswer(service: service, answer: true);
          case 1:
            await sendUserAnswer(service: service, answer: true);
          case 2:
            await sendUserAnswer(service: service, answer: false);
          case 3:
            await sendUserAnswer(service: service, answer: true);
          case 4:
            await sendUserAnswer(service: service, answer: true);
          case 5:
            await sendUserAnswer(service: service, answer: true);
          case 6:
            await sendUserAnswer(service: service, answer: false);
          case 7:
            await sendUserAnswer(service: service, answer: false);
          case 8:
            await sendUserAnswer(service: service, answer: false);
        }
      case "3_v_l":
        switch (iteration) {
          case 0:
            await sendUserAnswer(service: service, answer: false);
          case 1:
            await sendUserAnswer(service: service, answer: false);
          case 2:
            await sendUserAnswer(service: service, answer: true);
          case 3:
            await sendUserAnswer(service: service, answer: false);
          case 4:
            await sendUserAnswer(service: service, answer: true);
          case 5:
            await sendUserAnswer(service: service, answer: false);
          case 6:
            await sendUserAnswer(service: service, answer: true);
          case 7:
            await sendUserAnswer(service: service, answer: false);
          case 8:
            await sendUserAnswer(service: service, answer: false);
          case 9:
            await sendUserAnswer(service: service, answer: true);
        }
      case "5_h_r":
        switch (iteration) {
          case 0:
            await sendUserAnswer(service: service, answer: true);
          case 1:
            await sendUserAnswer(service: service, answer: true);
          case 2:
            await sendUserAnswer(service: service, answer: true);
          case 3:
            await sendUserAnswer(service: service, answer: false);
          case 4:
            await sendUserAnswer(service: service, answer: true);
          case 5:
            await sendUserAnswer(service: service, answer: true);
          case 6:
            await sendUserAnswer(service: service, answer: false);
          case 7:
            await sendUserAnswer(service: service, answer: false);
          case 8:
            await sendUserAnswer(service: service, answer: false);
        }
      case "6_v_l":
        switch (iteration) {
          case 0:
            await sendUserAnswer(service: service, answer: false);
          case 1:
            await sendUserAnswer(service: service, answer: false);
          case 2:
            await sendUserAnswer(service: service, answer: true);
          case 3:
            await sendUserAnswer(service: service, answer: false);
          case 4:
            await sendUserAnswer(service: service, answer: true);
          case 5:
            await sendUserAnswer(service: service, answer: false);
          case 6:
            await sendUserAnswer(service: service, answer: true);
          case 7:
            await sendUserAnswer(service: service, answer: true);
          case 8:
            await sendUserAnswer(service: service, answer: false);
        }
      case "7_h_r":
        switch (iteration) {
          case 0:
            await sendUserAnswer(service: service, answer: true);
          case 1:
            await sendUserAnswer(service: service, answer: false);
          case 2:
            await sendUserAnswer(service: service, answer: false);
          case 3:
            await sendUserAnswer(service: service, answer: false);
          case 4:
            await sendUserAnswer(service: service, answer: true);
          case 5:
            await sendUserAnswer(service: service, answer: true);
          case 6:
            await sendUserAnswer(service: service, answer: false);
          case 7:
            await sendUserAnswer(service: service, answer: true);
          case 8:
            await sendUserAnswer(service: service, answer: false);
        }
      case "8_h_r":
        switch (iteration) {
          case 0:
            await sendUserAnswer(service: service, answer: true);
          case 1:
            await sendUserAnswer(service: service, answer: false);
          case 2:
            await sendUserAnswer(service: service, answer: false);
          case 3:
            await sendUserAnswer(service: service, answer: true);
          case 4:
            await sendUserAnswer(service: service, answer: false);
          case 5:
            await sendUserAnswer(service: service, answer: true);
          case 6:
            await sendUserAnswer(service: service, answer: true);
          case 7:
            await sendUserAnswer(service: service, answer: true);
          case 8:
            await sendUserAnswer(service: service, answer: false);
        }
    }
    iteration++;
  }
}

void main() {
  Future<void> runTestSequenceWithNoLineSeenDistorted({
    required DistortionService service,
  }) async {
    for (final _ in service.manager.firstPartLines) {
      await sendUserAnswer(service: service, answer: true);
    }
  }

  Future<void> runTestSequenceWithOneLineSeenDistorted({
    required DistortionService service,
  }) async {
    for (final Line line in service.manager.firstPartLines) {
      final bool answer = !(line.name == "0_h_l" && !line.distorted);
      await sendUserAnswer(service: service, answer: answer);
    }
  }

  Future<void> runTestSequenceWithSevenLinesSeenDistorted({
    required DistortionService service,
  }) async {
    final List<String> linesSeenDistorted = [
      "0_v_r",
      "1_h_l",
      "3_v_l",
      "5_h_r",
      "6_v_l",
      "7_h_r",
      "8_h_r",
    ];
    for (final Line line in service.manager.firstPartLines) {
      final bool answer =
          !(linesSeenDistorted.contains(line.name) && !line.distorted);
      await sendUserAnswer(service: service, answer: answer);
    }
  }

  Future<void> runTestSequenceWithAllLineSeenDistorted({
    required DistortionService service,
  }) async {
    for (final _ in service.manager.firstPartLines) {
      await sendUserAnswer(service: service, answer: false);
    }
  }

  BinarySearch getBinarySearch({
    required DistortionService service,
    required String name,
  }) {
    return service.manager.binarySearches!
        .firstWhere((binarySearch) => binarySearch.line == name);
  }

  List<int?> getScore({
    required DistortionService service,
    required String name,
  }) {
    return service.manager.scores[name]!;
  }

  group('DistortionService', () {
    late DistortionService service;
    setUpAll(() async => setupTests());
    setUp(() async {
      service = await DistortionService.startService();
      setTimeStamps(service);
    });
    test('should be created without errors', () async {
      expect(
        () => service,
        returnsNormally,
      );
    });
    test('should stop all streams on stop()', () {
      expect(service.isRunning, true);
      service.stop();
      expect(service.isRunning, false);
    });
    test('should track missed lines in part 1', () async {
      await sendUserAnswer(service: service);
      expect(service.manager.missedFirstPartLines.length, 1);
    });
    test('should track user answer correctly', () async {
      await sendUserAnswer(service: service, answer: true);
      expect(
        service.manager.firstPartLines
            .where((line) => line.answer == true)
            .length,
        1,
      );
      await sendUserAnswer(service: service, answer: false);
      expect(
        service.manager.firstPartLines
            .where((line) => line.answer == false)
            .length,
        1,
      );
    });
    test('should create 36 straight and 4 distorted lines', () async {
      expect(service.manager.firstPartLinesStraight.length, 36);
      expect(service.manager.firstPartLinesDistorted.length, 4);
    });
    test('should create 10 straight and 2 distorted lines in presentation mode',
        () async {
      service = await DistortionService.startService(isPresentation: true);
      expect(service.manager.firstPartLinesStraight.length, 10);
      expect(service.manager.firstPartLinesDistorted.length, 2);
    });
    test("should stop test after first part if every line was seen as straight",
        () async {
      await runTestSequenceWithNoLineSeenDistorted(service: service);
      expect(service.manager.firstPartLinesSeenStraight.length, 36);
      expect(service.manager.firstPartLinesSeenDistorted, isEmpty);
      expect(service.manager.isSecondPart, true);
      expect(service.manager.scores.keys.length, 36);
      expect(
        service.manager.scores.values
            .every((value) => listEquals(value, [0, null])),
        true,
      );
      expect(service.manager.binarySearches, isEmpty);
      expect(service.isRunning, false);
    });
    test(
        "should not stop test after first part if at least one line was seen as distorted",
        () async {
      await runTestSequenceWithOneLineSeenDistorted(service: service);
      expect(service.manager.firstPartLinesSeenStraight.length, 35);
      expect(service.manager.firstPartLinesSeenDistorted.length, 1);
      expect(service.manager.isSecondPart, true);
      expect(service.manager.scores.containsKey("0_h_l"), false);
      expect(service.isRunning, true);
      expect(service.manager.binarySearches!.length, 1);
      expect(service.manager.binarySearches!.first.line, "0_h_l");
    });
    test("should create a maximum of 12 lines to follow in second part",
        () async {
      await runTestSequenceWithAllLineSeenDistorted(service: service);
      expect(service.manager.firstPartLinesSeenStraight, isEmpty);
      expect(service.manager.firstPartLinesSeenDistorted.length, 36);
      expect(service.manager.scores.keys.length, 24);
      expect(
        service.manager.scores.values
            .every((value) => listEquals(value, [0, null])),
        true,
      );
      expect(service.manager.binarySearches!.length, 12);
    });
    test("should decrease dot spacing if line was seen as straight", () async {
      await runTestSequenceWithOneLineSeenDistorted(service: service);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 10);
      await sendUserAnswer(service: service, answer: true);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 5);
      await sendUserAnswer(service: service, answer: true);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 2);
      await sendUserAnswer(service: service, answer: true);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 1);
    });
    test("should increase dot spacing if line was seen as distorted", () async {
      await runTestSequenceWithOneLineSeenDistorted(service: service);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 10);
      await sendUserAnswer(service: service, answer: false);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 15);
      await sendUserAnswer(service: service, answer: false);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 18);
      await sendUserAnswer(service: service, answer: false);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 19);
      await sendUserAnswer(service: service, answer: false);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 20);
    });
    test("should create a second binary search after first is finsihed",
        () async {
      await runTestSequenceWithOneLineSeenDistorted(service: service);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 10);
    });
    test(
        "should stop the service after all binary searches have finished twice",
        () async {
      await runTestSequenceWithOneLineSeenDistorted(service: service);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      expect(getBinarySearch(service: service, name: "0_h_l").dotSpacingId, 10);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      expect(service.isRunning, false);
    });
    test("should fill the score with the results of each binary search",
        () async {
      await runTestSequenceWithOneLineSeenDistorted(service: service);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: false);
      await sendUserAnswer(service: service, answer: false);
      await sendUserAnswer(service: service, answer: true);
      expect(
        listEquals(getScore(service: service, name: "0_h_l"), [48]),
        true,
      );
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: false);
      await sendUserAnswer(service: service, answer: false);
      await sendUserAnswer(service: service, answer: false);
      expect(
        listEquals(getScore(service: service, name: "0_h_l"), [48, 30]),
        true,
      );
    });
    test(
        "should have a score of 0 if all lines were seen as straight in second part",
        () async {
      await runTestSequenceWithOneLineSeenDistorted(service: service);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      await sendUserAnswer(service: service, answer: true);
      expect(
        listEquals(getScore(service: service, name: "0_h_l"), [0]),
        true,
      );
    });
    test(
        "should create a correct summary after all binary searches have finished",
        () async {
      await runTestSequenceWithSevenLinesSeenDistorted(service: service);
      final Map<String, BinarySearchIterator> iterators = {
        "0_v_r": BinarySearchIterator(line: "0_v_r"),
        "1_h_l": BinarySearchIterator(line: "1_h_l"),
        "3_v_l": BinarySearchIterator(line: "3_v_l"),
        "5_h_r": BinarySearchIterator(line: "5_h_r"),
        "6_v_l": BinarySearchIterator(line: "6_v_l"),
        "7_h_r": BinarySearchIterator(line: "7_h_r"),
        "8_h_r": BinarySearchIterator(line: "8_h_r"),
      };
      await Future.doWhile(() async {
        if (service.manager.binarySearches!.isEmpty) {
          return false;
        }
        await iterators[service.manager.current.name]!
            .moveForward(service: service);
        return true;
      });
      expect(
        listEquals(service.manager.summary.left.h, [24.0, 0.0, 0.0]),
        true,
      );
      expect(
        listEquals(service.manager.summary.left.v, [0.0, 93.0, 87.0]),
        true,
      );
      expect(
        listEquals(service.manager.summary.right.h, [0.0, 21.0, 57.0]),
        true,
      );
      expect(
        listEquals(service.manager.summary.right.v, [81.0, 0.0, 0.0]),
        true,
      );
    });
  });
}
