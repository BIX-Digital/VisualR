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

import 'package:visualr_app/common/models/coordinates.dart';
import 'package:visualr_app/contrast/models/color.dart';
import 'package:visualr_app/contrast/models/result.dart';
import 'package:visualr_app/contrast/models/step.dart';
import 'package:visualr_app/meta.dart';

class ContrastPresentationService {
  List<ContrastStep> steps = [];
  List<Color> colors;

  final List<EyeEnum> _eyes = [
    EyeEnum.right,
    EyeEnum.left,
    EyeEnum.left,
    EyeEnum.right,
    EyeEnum.left,
    EyeEnum.right,
    EyeEnum.left,
    EyeEnum.right,
    EyeEnum.left,
    EyeEnum.right,
    EyeEnum.right,
    EyeEnum.left,
  ];

  final List<List<Coordinates>> _coordinates = [
    [
      Coordinates(x: -13.0, y: -126.0),
      Coordinates(x: -72.0, y: 0.0),
      Coordinates(x: -157.0, y: -106.0),
      Coordinates(x: 130.0, y: 0.0),
      Coordinates(x: 157.0, y: 135.0),
      Coordinates(x: 16.0, y: 106.0),
      Coordinates(x: -151.0, y: 126.0),
    ],
    [
      Coordinates(x: -72.0, y: 0.0),
      Coordinates(x: -157.0, y: -106.0),
      Coordinates(x: 157.0, y: 135.0),
      Coordinates(x: -151.0, y: 126.0),
    ],
    [
      Coordinates(x: -13.0, y: -126.0),
      Coordinates(x: -72.0, y: 0.0),
      Coordinates(x: -157.0, y: -106.0),
      Coordinates(x: 130.0, y: 0.0),
      Coordinates(x: 157.0, y: 135.0),
      Coordinates(x: 16.0, y: 106.0),
    ],
    [
      Coordinates(x: -13.0, y: -126.0),
      Coordinates(x: 16.0, y: 106.0),
      Coordinates(x: -151.0, y: 126.0),
    ],
    [
      Coordinates(x: 130.0, y: 0.0),
      Coordinates(x: 157.0, y: 135.0),
      Coordinates(x: 16.0, y: 106.0),
      Coordinates(x: -151.0, y: 126.0),
    ],
    [
      Coordinates(x: -13.0, y: -126.0),
      Coordinates(x: -72.0, y: 0.0),
      Coordinates(x: 130.0, y: 0.0),
    ],
    [
      Coordinates(x: -13.0, y: -126.0),
      Coordinates(x: -72.0, y: 0.0),
      Coordinates(x: 157.0, y: 135.0),
      Coordinates(x: 16.0, y: 106.0),
      Coordinates(x: -151.0, y: 126.0),
    ],
    [
      Coordinates(x: -72.0, y: 0.0),
      Coordinates(x: -157.0, y: -106.0),
      Coordinates(x: 130.0, y: 0.0),
      Coordinates(x: 157.0, y: 135.0),
      Coordinates(x: 16.0, y: 106.0),
      Coordinates(x: -151.0, y: 126.0),
    ],
    [
      Coordinates(x: -157.0, y: -106.0),
      Coordinates(x: 16.0, y: 106.0),
      Coordinates(x: -151.0, y: 126.0),
    ],
    [
      Coordinates(x: -72.0, y: 0.0),
      Coordinates(x: 157.0, y: 135.0),
      Coordinates(x: 16.0, y: 106.0),
      Coordinates(x: -151.0, y: 126.0),
    ],
    [
      Coordinates(x: -13.0, y: -126.0),
      Coordinates(x: -72.0, y: 0.0),
      Coordinates(x: -157.0, y: -106.0),
      Coordinates(x: 130.0, y: 0.0),
      Coordinates(x: 157.0, y: 135.0),
      Coordinates(x: 16.0, y: 106.0),
      Coordinates(x: -151.0, y: 126.0),
    ],
    [
      Coordinates(x: -13.0, y: -126.0),
      Coordinates(x: -72.0, y: 0.0),
      Coordinates(x: -151.0, y: 126.0),
    ],
  ];

  static const List<Color> _darkColors = [
    Color(r: 35, g: 35, b: 35),
    Color(r: 35, g: 35, b: 35),
    Color(r: 31, g: 29, b: 29),
    Color(r: 29, g: 28, b: 28),
    Color(r: 27, g: 26, b: 28),
    Color(r: 27, g: 26, b: 28),
    Color(r: 31, g: 29, b: 29),
    Color(r: 29, g: 28, b: 28),
    Color(r: 27, g: 26, b: 28),
    Color(r: 28, g: 26, b: 27),
    Color(r: 29, g: 28, b: 28),
    Color(r: 31, g: 29, b: 29),
  ];

  static const List<Color> _lightColors = [
    Color(r: 131, g: 131, b: 131),
    Color(r: 131, g: 131, b: 131),
    Color(r: 157, g: 157, b: 157),
    Color(r: 164, g: 164, b: 164),
    Color(r: 177, g: 177, b: 177),
    Color(r: 177, g: 177, b: 177),
    Color(r: 157, g: 157, b: 157),
    Color(r: 164, g: 164, b: 164),
    Color(r: 177, g: 177, b: 177),
    Color(r: 176, g: 176, b: 176),
    Color(r: 164, g: 164, b: 164),
    Color(r: 157, g: 157, b: 157),
  ];

  ContrastPresentationService({
    required this.colors,
  }) {
    colors.asMap().forEach((index, color) {
      steps.add(
        ContrastStep(
          eye: _eyes[index],
          color: color,
          coordinates: _coordinates[index],
          contrastSensitivity: 0.0,
          step: index + 1,
          result: ContrastResult(
            numDisplayed: _coordinates[index].length,
            numSeen: _coordinates[index].length,
          ),
        ),
      );
    });
  }

  factory ContrastPresentationService.dark() {
    return ContrastPresentationService(colors: _darkColors);
  }

  factory ContrastPresentationService.light() {
    return ContrastPresentationService(colors: _lightColors);
  }
}
