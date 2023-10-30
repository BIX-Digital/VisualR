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
import 'package:visualr_app/common/models/coordinates.dart';

void main() {
  group('Coordinates', () {
    test('should parse JSON', () {
      final Coordinates coordinates = Coordinates.fromJson(
        {"x": 0.0, "y": 0.0},
      );
      expect(coordinates.x, 0.0);
      expect(coordinates.y, 0.0);
    });
    test('should be convertible to JSON', () {
      expect(Coordinates(x: 0.0, y: 0.0).toJson(), {"x": 0.0, "y": 0.0});
    });
    test('should create correct coordinates for the corresponding index', () {
      final List<Coordinates> possibleCoordinates = [
        Coordinates(x: 0.0, y: 0.0),
        Coordinates(x: 10.0, y: 10.0),
        Coordinates(x: 20.0, y: 20.0),
      ];
      expect(Coordinates.getCoordinates(possibleCoordinates, 2).x, 20.0);
    });
    test('should throw exception when a field is missing', () {
      expect(() => Coordinates.fromJson({"x": 0.0}), throwsFormatException);
    });
    test('should throw exception when a field is in the wrong format', () {
      expect(
        () => Coordinates.fromJson({"x": "0.0", "y": 0.0}),
        throwsFormatException,
      );
      expect(
        () => Coordinates.fromJson({"x": 0, "y": 0.0}),
        throwsFormatException,
      );
    });
  });
}
