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
import 'package:visualr_app/distortion/models/line.dart';
import 'package:visualr_app/distortion/models/orientation.dart';
import 'package:visualr_app/meta.dart';

import '../../data.dart';
import '../data.dart';

void main() {
  final Map<String, dynamic> json = {
    'name': "0_h_l",
    'id': 0,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'answerGivenAt': answerGivenAt.millisecondsSinceEpoch,
    'orientation': "horizontal",
    'eye': "left",
    'dotSpacingId': 18,
    'dotSpacing': 114.0,
    'length': 300.0,
    'coordinates': [
      {'x': -114.0, 'y': -360.0},
      {'x': 0.0, 'y': -360.0},
      {'x': 114.0, 'y': -360.0},
    ],
    'answer': true,
  };
  group(
    'Line',
    () {
      test('should decode line identifier correctly', () {
        expect(line.id, 3);
        expect(line.orientation, Orientation.vertical);
        expect(line.eye, EyeEnum.right);
      });
      test('should convert dot spacing ID to dot spacing in arc minutes', () {
        expect(line.dotSpacing, 30.0);
      });
      test('should get the correct line length per line ID', () {
        expect(line.length, 720.0);
      });
      test('should have fixed and dynamic coordinates', () {
        expect(
          verticalLine.coordinates[0].x,
          verticalLine.coordinates[1].x,
        );
        expect(
          verticalLine.coordinates[0].y,
          isNot(greaterThanOrEqualTo(verticalLine.coordinates[1].y)),
        );
        expect(
          horizontalLine.coordinates[0].y,
          horizontalLine.coordinates[1].y,
        );
        expect(
          horizontalLine.coordinates[0].x,
          isNot(greaterThanOrEqualTo(horizontalLine.coordinates[1].x)),
        );
      });
      test('should calculate amount of dots needed correctly', () {
        expect(line.coordinates.length, 25);
      });
      test('should throw an exception when line is created with unknown id',
          () {
        expect(() => Line(name: '12_v_r'), throwsFormatException);
      });
      test('should be convertible to JSON', () {
        final Line line = Line(name: "0_h_l", dotSpacingId: 18);
        line.answerGivenAt = answerGivenAt;
        line.createdAt = createdAt;
        line.answer = true;
        expect(line.toJson(), json);
      });
    },
  );
}
