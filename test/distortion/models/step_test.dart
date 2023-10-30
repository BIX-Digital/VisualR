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
import 'package:visualr_app/distortion/models/step.dart';

import '../../data.dart';
import '../data.dart';

void main() {
  final Map<String, dynamic> json = {
    "line": "0_h_l",
    "createdAt": createdAt.millisecondsSinceEpoch,
    "answerGivenAt": answerGivenAt.millisecondsSinceEpoch,
    "dotSpacing": 10,
    "answer": true,
  };
  group('DistortionStep', () {
    test('should be created without errors', () {
      expect(
        () => distortionStep,
        returnsNormally,
      );
    });
    test('should parse JSON', () {
      final DistortionStep distortionStepFromJson =
          DistortionStep.fromJson(json);
      expect(distortionStepFromJson.answer, distortionStep.answer);
      expect(distortionStepFromJson.line, distortionStep.line);
      expect(distortionStepFromJson.dotSpacing, distortionStep.dotSpacing);
    });
    test('should be convertible to JSON', () {
      expect(distortionStep.toJson(), json);
    });
  });
}
