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

import 'package:visualr_app/common/models/user.dart';
import 'package:visualr_app/distortion/models/app_meta.dart';
import 'package:visualr_app/distortion/models/step.dart';
import 'package:visualr_app/distortion/models/summary.dart';

class DistortionTest {
  int id;
  DateTime createdAt;
  User user;
  DistortionAppMeta appMeta;
  DistortionSummary summary;
  Map<String, List<int?>> scores;
  List<String> part1;
  List<String> missedPart1;
  List<DistortionStep> part2;

  DistortionTest({
    this.id = 0,
    required this.createdAt,
    required this.user,
    required this.appMeta,
    required this.summary,
    required this.scores,
    required this.part1,
    required this.missedPart1,
    this.part2 = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'user': user.toJson(),
      'appMeta': appMeta.toJson(),
      'summary': summary.toJson(),
      'scores': scores,
      'missedPart1': missedPart1,
      'part1': part1,
      'part2': part2.map((step) => step.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
