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
import 'package:visualr_app/contrast/models/app_meta.dart';

import '../data.dart';

void main() {
  final Map<String, dynamic> json = {
    "appVersion": '1.0.0',
    "buildNumber": '1',
    "device": 'iPhone 12,1',
    "locale": 'en',
    "screenBrightness": 0.5,
  };
  final Map<String, dynamic> jsonWithMissingField = {
    "appVersion": '1.0.0',
    "buildNumber": '1',
    "device": 'iPhone 12,1',
    "locale": 'en',
  };
  final Map<String, dynamic> jsonWithWronglyTypedField = {
    "appVersion": '1.0.0',
    "buildNumber": 1,
    "device": 'iPhone 12,1',
    "locale": 'en',
    "screenBrightness": 0.5,
  };
  group('ContrastAppMeta', () {
    test('should be created without errors', () {
      expect(
        () => appMeta,
        returnsNormally,
      );
    });
    test('should parse JSON', () {
      final ContrastAppMeta appMeta = ContrastAppMeta.fromJson(json);
      expect(appMeta.appVersion, '1.0.0');
      expect(appMeta.screenBrightness, 0.5);
    });
    test('should be convertible to JSON', () {
      expect(appMeta.toJson(), json);
    });
    test('should throw exception when a field is missing', () {
      expect(
        () => ContrastAppMeta.fromJson(jsonWithMissingField),
        throwsFormatException,
      );
    });
    test('should throw exception when a field is in the wrong format', () {
      expect(
        () => ContrastAppMeta.fromJson(jsonWithWronglyTypedField),
        throwsFormatException,
      );
    });
  });
}
