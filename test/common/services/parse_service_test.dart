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
import 'package:visualr_app/common/services/parse_service.dart';

void main() {
  final Map<String, dynamic> json = {
    'key': 'test',
  };
  final Map<String, dynamic> jsonWithNullValue = {
    'key': null,
  };
  final Map<String, dynamic> jsonWithList = {
    'key': [1, 2, 3],
  };
  final Map<String, dynamic> jsonWithWronglyTypedList = {
    'key': 'notalist',
  };
  final Map<String, dynamic> jsonWithListWithWronglyTypedElement = {
    'key': [1, 'two', 3],
  };
  group('ParseService', () {
    group('duration', () {
      test("should parse duration string", () {
        expect(
          ParseService.duration("1:25.500"),
          const Duration(minutes: 1, seconds: 25, milliseconds: 500),
        );
      });
    });
    group('cast', () {
      test('should convert JSON field to specified type', () {
        expect(
          () => ParseService.cast<String>(json['key'], 'key'),
          returnsNormally,
        );
      });
      test('should throw error if JSON field is not of specified type', () {
        expect(
          () => ParseService.cast<int>(json['key'], 'key'),
          throwsFormatException,
        );
      });
      test('should throw error if JSON field is null', () {
        expect(
          () => ParseService.cast<String>(jsonWithNullValue['key'], 'key'),
          throwsFormatException,
        );
      });
    });

    group('tryCast', () {
      test('should convert JSON field to specified type', () {
        expect(
          () => ParseService.tryCast<String>(json['key']),
          returnsNormally,
        );
      });
      test('should return null if JSON field is not of specified type', () {
        expect(
          ParseService.tryCast<int>(json['key']),
          null,
        );
      });
      test('should allow for null values', () {
        expect(
          ParseService.tryCast<String>(jsonWithNullValue['key']),
          null,
        );
      });
    });
    group('castList', () {
      test('should convert JSON field to list', () {
        expect(
          () => ParseService.castList<int>(jsonWithList['key'], 'key'),
          returnsNormally,
        );
      });
      test('should throw error if JSON field is not a list', () {
        expect(
          () => ParseService.castList<int>(
            jsonWithWronglyTypedList['key'],
            'key',
          ),
          throwsFormatException,
        );
      });
      test('should throw error if element in list is not of specified type',
          () {
        expect(
          () => ParseService.castList<String>(
            jsonWithListWithWronglyTypedElement['key'],
            'key',
          ),
          throwsFormatException,
        );
      });
    });
  });
}
