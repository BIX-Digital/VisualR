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
import 'package:visualr_app/contrast/models/test.dart';
import 'package:visualr_app/contrast/models/test.model.dart';

import '../../data.dart';
import '../data.dart';

void main() {
  final Map<String, dynamic> json = {
    "appMeta": {
      "appVersion": '1.0.0',
      "buildNumber": '1',
      "device": 'iPhone 12,1',
      "locale": 'en',
      "screenBrightness": 0.5,
    },
    "backgroundColor": {"r": 26, "g": 26, "b": 26},
    "createdAt": createdAt.millisecondsSinceEpoch,
    "steps": [
      {
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
        "isFake": false,
        "step": 1,
      }
    ],
    "summary": {
      "left": {"avg": 1.2, "std": 0.2},
      "right": {"avg": 1.4, "std": 0.3},
    },
    "user": {
      "displayName": "User",
      "id": "user_id",
    },
    "id": 1,
  };
  group('ContrastTest', () {
    test('should be created without errors', () {
      expect(
        () => contrastTest,
        returnsNormally,
      );
    });
    test('should be convertible to JSON', () {
      expect(contrastTest.toJson(), json);
    });
    test('should be created from entity', () {
      final ContrastTestEntity entity = ContrastTestEntity(
        appMeta: appMeta.toString(),
        steps: [contrastStep.toString()],
        backgroundColor: backgroundColor.toString(),
        createdAt: createdAt,
        summary: contrastSummary.toString(),
        user: user.toString(),
        id: 1,
        isDark: true,
      );
      final ContrastTest sequenceFromEntity = entity.toDTO();
      expect(sequenceFromEntity.appMeta.appVersion, '1.0.0');
      expect(sequenceFromEntity.backgroundColor.r, 26);
      expect(sequenceFromEntity.createdAt, createdAt);
      expect(sequenceFromEntity.id, 1);
      expect(sequenceFromEntity.summary.left!.avg, 1.2);
      expect(sequenceFromEntity.user.displayName, 'User');
    });
  });
}
