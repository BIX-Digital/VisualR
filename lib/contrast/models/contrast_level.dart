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

import 'package:visualr_app/contrast/models/color.dart';

const String defaultDevice = 'iPhone14,5';

class ContrastLevel {
  final Color color;
  final bool darkBackground;
  final double contrast;
  final String device;

  const ContrastLevel({
    required this.color,
    required this.contrast,
    this.darkBackground = true,
    this.device = defaultDevice,
  });
}

const List<ContrastLevel> listOfContrastLevels = [
  ContrastLevel(
    color: Color(r: 45, g: 45, b: 45),
    contrast: 0.150,
  ),
  ContrastLevel(
    color: Color(r: 35, g: 35, b: 35),
    contrast: 0.311,
  ),
  ContrastLevel(
    color: Color(r: 32, g: 32, b: 32),
    contrast: 0.424,
  ),
  ContrastLevel(
    color: Color(r: 31, g: 29, b: 29),
    contrast: 0.604,
  ),
  ContrastLevel(
    color: Color(r: 29, g: 28, b: 28),
    contrast: 0.762,
  ),
  ContrastLevel(
    color: Color(r: 29, g: 27, b: 29),
    contrast: 0.891,
  ),
  ContrastLevel(
    color: Color(r: 27, g: 27, b: 27),
    contrast: 1.068,
  ),
  ContrastLevel(
    color: Color(r: 26, g: 27, b: 26),
    contrast: 1.205,
  ),
  ContrastLevel(
    color: Color(r: 28, g: 26, b: 27),
    contrast: 1.357,
  ),
  ContrastLevel(
    color: Color(r: 27, g: 26, b: 28),
    contrast: 1.492,
  ),
  ContrastLevel(
    color: Color(r: 27, g: 26, b: 27),
    contrast: 1.607,
  ),
  ContrastLevel(
    color: Color(r: 27, g: 26, b: 26),
    contrast: 1.729,
  ),
  ContrastLevel(
    color: Color(r: 26, g: 26, b: 28),
    contrast: 1.902,
  ),
  ContrastLevel(
    color: Color(r: 26, g: 26, b: 27),
    contrast: 2.201,
  ),
  ContrastLevel(
    color: Color(r: 102, g: 102, b: 102),
    contrast: 0.149,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 131, g: 131, b: 131),
    contrast: 0.302,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 147, g: 147, b: 147),
    contrast: 0.454,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 157, g: 157, b: 157),
    contrast: 0.593,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 164, g: 164, b: 164),
    contrast: 0.747,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 169, g: 169, b: 169),
    contrast: 0.917,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 172, g: 172, b: 172),
    contrast: 1.058,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 174, g: 174, b: 174),
    contrast: 1.197,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 176, g: 176, b: 176),
    contrast: 1.396,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 177, g: 177, b: 177),
    contrast: 1.523,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 178, g: 178, b: 178),
    contrast: 1.675,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 177, g: 179, b: 179),
    contrast: 1.891,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 178, g: 179, b: 179),
    contrast: 1.976,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 179, g: 179, b: 179),
    contrast: 2.068,
    darkBackground: false,
  ),
  ContrastLevel(
    color: Color(r: 180, g: 179, b: 180),
    contrast: 2.471,
    darkBackground: false,
  ),
];
