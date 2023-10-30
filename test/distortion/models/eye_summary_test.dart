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

import '../data.dart';

void main() {
  final Map<String, dynamic> jsonFromServer = {
    "h": [10.0, 9.5, 8.0],
    "v": [15.5, 16.0, 14.5],
  };
  final Map<String, dynamic> convertedJson = {
    "h": [66.0, 63.0, 54.0],
    "v": [99.0, 102.0, 93.0],
  };
  group('DistortionEyeSummary', () {
    test('should be created without errors', () {
      expect(
        () => eyeSummary,
        returnsNormally,
      );
    });
    test('should parse JSON', () {
      final DistortionEyeSummary eyeSummaryFromServerJson =
          DistortionEyeSummary.fromJson(jsonFromServer);
      expect(eyeSummaryFromServerJson.h, eyeSummary.h);
      expect(eyeSummaryFromServerJson.v, eyeSummary.v);
      final DistortionEyeSummary eyeSummaryFromJson =
          DistortionEyeSummary.fromJsonWithoutConversion(convertedJson);
      expect(eyeSummaryFromJson.h, eyeSummary.h);
      expect(eyeSummaryFromJson.v, eyeSummary.v);
    });
    test('should be convertible to JSON', () {
      expect(eyeSummary.toJson(), convertedJson);
    });
    test('should throw exception when a field is missing', () {
      expect(
        () => DistortionEyeSummary.fromJson({
          "h": [90, 102, 96],
        }),
        throwsFormatException,
      );
    });
    test('should throw exception when a field is in the wrong format', () {
      expect(
        () => DistortionEyeSummary.fromJson({
          "h": ["90", "102", "96"],
          "v": [96, 96, 96],
        }),
        throwsFormatException,
      );
    });
  });
}
