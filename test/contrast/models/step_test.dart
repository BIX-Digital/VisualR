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

import '../../data.dart';
import '../data.dart';

void main() {
  final Map<String, dynamic> json = {
    "eye": "left",
    "color": {"r": 31, "g": 31, "b": 31},
    "coordinates": [
      {"x": 100, "y": 100},
      {"x": 200, "y": 200},
      {"x": 300, "y": 300},
    ],
    "contrastSensitivity": 0.5,
    "result": {
      "numDisplayed": 3,
      "numSeen": 3,
    },
    "createdAt": createdAt.millisecondsSinceEpoch,
    "answerGivenAt": answerGivenAt.millisecondsSinceEpoch,
    "step": 1,
    "isFake": false,
  };
  final Map<String, dynamic> unityJson = {
    "eye": "left",
    "color": {"r": 31, "g": 31, "b": 31},
    "coordinates": [
      {"x": 100, "y": 100},
      {"x": 200, "y": 200},
      {"x": 300, "y": 300},
    ],
    "diameter": {"outer": 90.0, "inner": 54.0},
  };
  group(
    'ContrastTestStep',
    () {
      test('should be created without errors', () {
        expect(
          () => contrastStep,
          returnsNormally,
        );
      });
      test('should be convertible to JSON', () {
        expect(contrastStep.toJson(), json);
        expect(contrastStep.toUnityJson(), unityJson);
      });
    },
  );
}
