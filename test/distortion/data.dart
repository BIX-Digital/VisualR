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

import 'package:visualr_app/distortion/models/app_meta.dart';
import 'package:visualr_app/distortion/models/binary_search.dart';
import 'package:visualr_app/distortion/models/eye_summary.dart';
import 'package:visualr_app/distortion/models/line.dart';
import 'package:visualr_app/distortion/models/orientation.dart';
import 'package:visualr_app/distortion/models/processed_name.dart';
import 'package:visualr_app/distortion/models/step.dart';
import 'package:visualr_app/distortion/models/summary.dart';
import 'package:visualr_app/distortion/models/test.dart';
import 'package:visualr_app/meta.dart';

import '../data.dart';

final DistortionAppMeta appMeta = DistortionAppMeta(
  appVersion: '1.0.0',
  buildNumber: '1',
  locale: 'en',
  device: 'iPhone 12,1',
);

final BinarySearch binarySearch = BinarySearch(line: "0_h_l");

final Line line = Line(name: '3_v_r', dotSpacingId: 4);
final Line verticalLine = Line(name: '3_v_r', dotSpacingId: 4);
final Line horizontalLine = Line(name: '3_h_r', dotSpacingId: 4);

final Map<String, List<int?>> scores = {
  "0_h_l": [0, null],
  "0_h_r": [0, null],
  "0_v_l": [0, null],
  "0_v_r": [0, null],
  "1_h_l": [0, null],
  "1_h_r": [0, null],
  "1_v_l": [0, null],
  "1_v_r": [0, null],
  "2_h_l": [0, null],
  "2_h_r": [0, null],
  "2_v_l": [0, null],
  "2_v_r": [0, null],
  "3_h_l": [0, null],
  "3_h_r": [0, null],
  "3_v_l": [0, null],
  "3_v_r": [0, null],
  "4_h_l": [0, null],
  "4_h_r": [0, null],
  "4_v_l": [0, null],
  "4_v_r": [0, null],
  "5_h_l": [0, null],
  "5_h_r": [0, null],
  "5_v_l": [0, null],
  "5_v_r": [0, null],
  "6_h_l": [0, null],
  "6_h_r": [0, null],
  "6_v_l": [0, null],
  "6_v_r": [0, null],
  "7_h_l": [0, null],
  "7_h_r": [0, null],
  "7_v_l": [0, null],
  "7_v_r": [0, null],
  "8_h_l": [0, null],
  "8_h_r": [0, null],
  "8_v_l": [0, null],
  "8_v_r": [0, null],
};

final DistortionStep distortionStep = DistortionStep(
  answer: true,
  answerGivenAt: answerGivenAt,
  createdAt: createdAt,
  dotSpacing: 10,
  line: "0_h_l",
);

final DistortionTest distortionTest = DistortionTest(
  appMeta: appMeta,
  createdAt: createdAt,
  missedPart1: [],
  part1: [],
  scores: scores,
  summary: distortionSummary,
  user: user,
);

final DistortionEyeSummary eyeSummary = DistortionEyeSummary(
  h: [66.0, 63.0, 54.0],
  v: [99.0, 102.0, 93.0],
);

final DistortionEyeSummary eyeSummaryZero = DistortionEyeSummary(
  h: [0.0, 0.0, 0.0],
  v: [0.0, 0.0, 0.0],
);

final DistortionSummary distortionSummary = DistortionSummary(
  left: eyeSummary,
  right: eyeSummary,
);

final DistortionSummary distortionSummaryZero = DistortionSummary(
  left: eyeSummaryZero,
  right: eyeSummaryZero,
);

final ProcessedName processedName = ProcessedName(
  id: 0,
  eye: EyeEnum.left,
  orientation: Orientation.horizontal,
);
