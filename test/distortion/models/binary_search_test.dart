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
import 'package:visualr_app/distortion/models/binary_search.dart';

import '../data.dart';

void main() {
  final Map<String, dynamic> json = {
    "dotSpacingId": 10,
    "lowerLimit": 0,
    "upperLimit": 21,
    "line": "0_h_l",
  };
  group('BinarySearch', () {
    test('should be created without errors', () {
      expect(
        () => binarySearch,
        returnsNormally,
      );
    });
    test('should parse JSON', () {
      final BinarySearch binarySearchFromJson = BinarySearch.fromJson(json);
      expect(binarySearchFromJson.dotSpacingId, 10);
      expect(binarySearchFromJson.lowerLimit, 0);
      expect(binarySearchFromJson.upperLimit, 21);
    });
    test('should be convertible to JSON', () {
      expect(binarySearch.toJson(), json);
    });
    test('should throw exception when a field is missing', () {
      expect(
        () => BinarySearch.fromJson({
          "dotSpacing": 10,
          "lowerLimit": 0,
          "line": "0_h_l",
        }),
        throwsFormatException,
      );
    });
    test('should throw exception when a field is in the wrong format', () {
      expect(
        () => BinarySearch.fromJson({
          "dotSpacingId": "10",
          "lowerLimit": 0,
          "upperLimit": 21,
          "line": "0_h_l",
        }),
        throwsFormatException,
      );
    });
  });
}
