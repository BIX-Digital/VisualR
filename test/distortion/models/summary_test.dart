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
import 'package:visualr_app/distortion/models/eye_summary.dart';
import 'package:visualr_app/distortion/models/summary.dart';

import '../data.dart';

void main() {
  final Map<String, dynamic> jsonFromServer = {
    "left": {
      "h": [10.0, 9.5, 8.0],
      "v": [15.5, 16.0, 14.5],
    },
    "right": {
      "h": [10.0, 9.5, 8.0],
      "v": [15.5, 16.0, 14.5],
    },
  };
  final Map<String, dynamic> convertedJson = {
    "left": {
      "h": [66.0, 63.0, 54.0],
      "v": [99.0, 102.0, 93.0],
    },
    "right": {
      "h": [66.0, 63.0, 54.0],
      "v": [99.0, 102.0, 93.0],
    },
  };
  group('DistortionEyeSummary', () {
    test('should be created without errors', () {
      expect(
        () => distortionSummary,
        returnsNormally,
      );
    });
    test('should parse JSON', () {
      final DistortionSummary summaryFromServerJson =
          DistortionSummary.fromJson(jsonFromServer);
      expect(summaryFromServerJson.left, distortionSummary.left);
      expect(summaryFromServerJson.right, distortionSummary.right);
      final DistortionSummary summaryFromJson =
          DistortionSummary.fromJsonWithoutConversion(convertedJson);
      expect(summaryFromJson.left, distortionSummary.left);
      expect(summaryFromJson.right, distortionSummary.right);
    });
    test('should be convertible to JSON', () {
      expect(distortionSummary.toJson(), convertedJson);
    });
    test('should throw exception when a field is missing', () {
      expect(
        () => DistortionSummary.fromJson({
          "left": {
            "h": [10.0, 9.5],
            "v": [15.5, 16.0],
          },
        }),
        throwsFormatException,
      );
    });
    test('should throw exception when a field is in the wrong format', () {
      expect(
        () => DistortionEyeSummary.fromJson({
          "left": {
            "h": [10.0, 9.5, 8.0],
            "v": [15.5, 16.0, 14.5],
          },
          "right": [10.0, 9.5, 8.0],
        }),
        throwsFormatException,
      );
    });
  });
}
