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

import 'dart:convert';

import 'package:visualr_app/contrast/models/test.dart';
import 'package:visualr_app/distortion/models/test.dart';
import 'package:visualr_app/ipda/models/ipda.dart';
import 'package:visualr_app/reading_speed/models/sequence.dart';

class ExportData {
  List<IPDA> ipda;
  List<ContrastTest> contrastDark;
  List<ContrastTest> contrastLight;
  List<DistortionTest> distortion;
  List<ReadingSpeedTestSequence> readingSpeed;
  ExportData({
    required this.ipda,
    required this.contrastDark,
    required this.contrastLight,
    required this.distortion,
    required this.readingSpeed,
  });

  Map<String, dynamic> toJson() {
    return {
      'ipda': ipda.map((sequence) => sequence.toJson()).toList(),
      'contrastDark':
          contrastDark.map((sequence) => sequence.toJson()).toList(),
      'contrastLight':
          contrastLight.map((sequence) => sequence.toJson()).toList(),
      'distortion': distortion.map((test) => test.toJson()).toList(),
      'readingSpeed':
          readingSpeed.map((sequence) => sequence.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
