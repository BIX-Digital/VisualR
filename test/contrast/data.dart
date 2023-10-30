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
import 'package:visualr_app/contrast/models/app_meta.dart';
import 'package:visualr_app/contrast/models/color.dart';
import 'package:visualr_app/contrast/models/diameter.dart';
import 'package:visualr_app/contrast/models/result.dart';
import 'package:visualr_app/contrast/models/step.dart';
import 'package:visualr_app/contrast/models/summary.dart';
import 'package:visualr_app/contrast/models/test.dart';
import 'package:visualr_app/meta.dart';

import '../data.dart';

final ContrastAppMeta appMeta = ContrastAppMeta(
  appVersion: '1.0.0',
  buildNumber: '1',
  locale: 'en',
  device: 'iPhone 12,1',
  screenBrightness: 0.5,
);

const backgroundColor = Color(r: 26, g: 26, b: 26);

const color = Color(r: 31, g: 31, b: 31);

final Diameter diameter = Diameter(outer: 90.0, inner: 54.0);

final ContrastTest contrastTest = ContrastTest(
  appMeta: appMeta,
  backgroundColor: backgroundColor,
  createdAt: createdAt,
  steps: [contrastStep],
  summary: contrastSummary,
  user: user,
  id: 1,
  isDark: true,
);

final ContrastStep contrastStep = ContrastStep(
  eye: EyeEnum.left,
  color: color,
  coordinates: [
    Coordinates(x: 100.0, y: 100.0),
    Coordinates(x: 200.0, y: 200.0),
    Coordinates(x: 300.0, y: 300.0),
  ],
  contrastSensitivity: 0.5,
  result: result,
  createdAt: createdAt,
  answerGivenAt: answerGivenAt,
  step: 1,
);

final ContrastResult result = ContrastResult(
  numDisplayed: 3,
  numSeen: 3,
);

final ContrastSummary contrastSummary = ContrastSummary(
  left: ContrastEyeSummary(avg: 1.2, std: 0.2),
  right: ContrastEyeSummary(avg: 1.4, std: 0.3),
);
