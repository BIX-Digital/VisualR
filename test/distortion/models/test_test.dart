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
    'id': 0,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'user': user.toJson(),
    'appMeta': appMeta.toJson(),
    'summary': distortionSummary.toJson(),
    'scores': scores,
    'missedPart1': [],
    'part1': [],
    'part2': [],
  };
  group('DistortionTest', () {
    test('should be created without errors', () {
      expect(
        () => distortionTest,
        returnsNormally,
      );
    });
    test('should be convertible to JSON', () {
      expect(distortionTest.toJson(), json);
    });
  });
}
