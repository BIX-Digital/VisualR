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
import 'package:visualr_app/common/models/display_size.dart';

void main() {
  final DisplaySize displaySize = DisplaySize(
    dpi: 460.0,
    height: 1080.0,
    width: 1920.0,
  );
  final Map<String, dynamic> json = {
    "dpi": 460.0,
    "height": 1080.0,
    "width": 1920.0,
  };
  final Map<String, dynamic> jsonWithMissingField = {
    "dpi": 460.0,
    "height": 1080.0,
  };
  final Map<String, dynamic> jsonWithWronglyTypedField = {
    "dpi": 460.0,
    "height": '1080.0',
    "width": 1920.0,
  };
  group('DisplaySize', () {
    test('should be created without errors', () {
      expect(
        () => displaySize,
        returnsNormally,
      );
    });
    test('should parse JSON', () {
      final DisplaySize displaySize = DisplaySize.fromJson(json);
      expect(displaySize.dpi, 460.0);
      expect(displaySize.height, 1080.0);
      expect(displaySize.width, 1920.0);
    });
    test('should be convertible to JSON', () {
      expect(displaySize.toJson(), json);
    });
    test('should throw exception when a field is missing', () {
      expect(
        () => DisplaySize.fromJson(jsonWithMissingField),
        throwsFormatException,
      );
    });
    test('should throw exception when a field is in the wrong format', () {
      expect(
        () => DisplaySize.fromJson(jsonWithWronglyTypedField),
        throwsFormatException,
      );
    });
  });
}
