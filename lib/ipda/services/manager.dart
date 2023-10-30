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

import 'package:collection/collection.dart';
import 'package:visualr_app/ipda/models/answers.dart';
import 'package:visualr_app/ipda/models/step.dart';

class IPDAManager {
  late IPDAStep _current;
  IPDAAnswers answers = IPDAAnswers(raw: [], decoded: []);
  final List<List<int>> steps = [
    [3, 6, 9],
    [1, 4, 7],
    [2, 5, 8],
  ];
  static Future<IPDAManager> startManager() async {
    final manager = IPDAManager();
    final IPDAStep? currentTest = await manager.createTestEvent();
    if (currentTest != null) {
      manager._current = currentTest;
    }
    return manager;
  }

  Future<IPDAStep?> createTestEvent() async {
    final int step = answers.raw.length + 1;
    if (step < 4) {
      return IPDAStep(
        ipdaValues: steps[answers.raw.length]
            .map((step) => calculatePupillaryDistancePerStep(step))
            .toList(),
        step: step,
      );
    }
    if (step == 4) {
      return IPDAStep(
        ipdaValues: answers.decoded
            .map((answer) => calculatePupillaryDistancePerStep(answer))
            .sorted((a, b) => b.compareTo(a)),
        step: step,
      );
    }
    return null;
  }

  void updateTestResults({required int answer}) {
    final int step = answers.raw.length + 1;
    if (step == 4) {
      answers.decoded
          .add(answers.decoded.sorted((a, b) => a.compareTo(b))[answer - 1]);
    } else {
      answers.decoded.add(steps[step - 1][answer - 1]);
    }
    answers.raw.add(answer);
  }

  double calculatePupillaryDistancePerStep(int step) {
    return 75 - (25 / 8) * (step - 1);
  }

  IPDAStep get current => _current;
}
