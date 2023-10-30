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
import 'package:visualr_app/contrast/services/service.dart';
import 'package:visualr_app/meta.dart';

import '../../setup.dart';

void setTimeStamps(ContrastService service) {
  service.manager.current.createdAt = DateTime.now();
  service.manager.current.answerGivenAt = DateTime.now();
}

Future<void> sendUserAnswer({
  required ContrastService service,
  required int answer,
}) async {
  service.incomingStream.add(answer);
  setTimeStamps(service);
  return Future.delayed(Duration.zero);
}

Future<void> runTestSequenceWithNoRingsSeen({
  required ContrastService service,
}) async {
  final List<bool> steps = List.filled(8, false);
  await runTestSequence(service: service, steps: steps);
}

Future<void> runTestSequenceWithAllRingsSeen({
  required ContrastService service,
}) async {
  final List<bool> steps = List.filled(21, true);
  await runTestSequence(service: service, steps: steps);
}

/// Runs a contrast test sequence with the specified inputs.
/// Takes the `ContrastService` and a `List<bool>`. For every false value in
/// the list the answer will be 0 and for every true value the answer will be
/// equal to the amount of rings visible on the screen.
Future<void> runTestSequence({
  required ContrastService service,
  required List<bool> steps,
}) async {
  int leftIteration = 0;
  int rightIteration = 0;
  await Future.doWhile(() async {
    if (service.manager.isFinished) {
      return false;
    }
    if (service.manager.current.isFake) {
      await sendUserAnswer(service: service, answer: 0);
      return true;
    }
    if (service.manager.current.eye == EyeEnum.left) {
      await moveForward(
        service: service,
        iteration: leftIteration,
        steps: steps,
      );
      leftIteration++;
      return true;
    }
    if (service.manager.current.eye == EyeEnum.right) {
      await moveForward(
        service: service,
        iteration: rightIteration,
        steps: steps,
      );
      rightIteration++;
      return true;
    }
    return true;
  });
}

Future<void> moveForward({
  required ContrastService service,
  required int iteration,
  required List<bool> steps,
}) async {
  steps[iteration]
      ? await sendUserAnswer(
          service: service,
          answer: service.manager.current.coordinates.length,
        )
      : await sendUserAnswer(
          service: service,
          answer: 0,
        );
}

void main() {
  group("ContrastTestService", () {
    late ContrastService service;
    setUpAll(() async => setupTests());
    setUp(() async {
      service = await ContrastService.startService();
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
    test('should track user answer correctly', () async {
      await sendUserAnswer(service: service, answer: 5);
      expect(
        service.manager.steps.where((step) => step.result?.numSeen == 5).length,
        1,
      );
    });
    test("should go through full test sequence", () async {
      await runTestSequenceWithNoRingsSeen(service: service);
      expect(service.isRunning, false);
    });
    test("should have 8 iterations per eye if no rings were seen", () async {
      await runTestSequenceWithNoRingsSeen(service: service);
      expect(
        service.manager.steps
            .where((step) => !step.isFake && step.eye == EyeEnum.left)
            .length,
        8,
      );
      expect(
        service.manager.steps
            .where((step) => !step.isFake && step.eye == EyeEnum.right)
            .length,
        8,
      );
    });
    test("should create a summary if no rings were seen", () async {
      await runTestSequenceWithNoRingsSeen(service: service);
      expect(service.manager.summary!.left!.avg, 0.15);
      expect(service.manager.summary!.left!.std, 0);
      expect(service.manager.summary!.right!.avg, 0.15);
      expect(service.manager.summary!.right!.std, 0);
    });
    test("should create a summary for a normal test sequence", () async {
      final List<bool> steps = [
        true,
        true,
        true,
        false,
        false,
        true,
        true,
        true,
        false,
        true,
        false,
        false,
        true,
        false,
        false,
        true,
      ];
      await runTestSequence(service: service, steps: steps);
      expect(service.manager.summary!.left!.avg, 0.578);
      expect(service.manager.summary!.left!.std, 0.068);
      expect(service.manager.summary!.right!.avg, 0.578);
      expect(service.manager.summary!.right!.std, 0.068);
    });
    test("should create a summary if all rings were seen", () async {
      await runTestSequenceWithAllRingsSeen(service: service);
      expect(service.manager.summary!.left!.avg, 2.201);
      expect(service.manager.summary!.left!.std, 0);
      expect(service.manager.summary!.right!.avg, 2.201);
      expect(service.manager.summary!.right!.std, 0);
    });
    test("should go through mock test in presentation mode", () async {
      service = await ContrastService.startService(isPresentation: true);
      for (int i = 0; i < 12; i++) {
        await sendUserAnswer(
          service: service,
          answer: service.manager.current.coordinates.length,
        );
      }
      expect(service.manager.steps.length, 12);
      expect(service.isRunning, false);
    });
  });
}
