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

import 'package:objectbox/objectbox.dart';
import 'package:visualr_app/common/models/user.dart';
import 'package:visualr_app/distortion/models/app_meta.dart';
import 'package:visualr_app/distortion/models/step.dart';
import 'package:visualr_app/distortion/models/summary.dart';
import 'package:visualr_app/distortion/models/test.dart';
import 'package:visualr_app/objectbox.g.dart';

@Entity()
class DistortionTestEntity {
  int id;
  @Property(type: PropertyType.date)
  DateTime createdAt;
  String user;
  String appMeta;
  String summary;
  String scores;
  List<String> part1;
  List<String> missedPart1;
  List<String> part2;

  DistortionTestEntity({
    this.id = 0,
    required this.user,
    required this.createdAt,
    required this.appMeta,
    required this.summary,
    required this.scores,
    required this.part1,
    required this.missedPart1,
    required this.part2,
  });

  factory DistortionTestEntity.fromDTO({required DistortionTest test}) {
    return DistortionTestEntity(
      user: test.user.toString(),
      createdAt: test.createdAt,
      appMeta: test.appMeta.toString(),
      summary: test.summary.toString(),
      scores: json.encode(test.scores),
      part1: test.part1,
      missedPart1: test.missedPart1,
      part2: test.part2.map((step) => step.toString()).toList(),
    );
  }

  DistortionTest toDTO() {
    return DistortionTest(
      id: id,
      createdAt: createdAt,
      user: User.fromJson(json.decode(user) as Map<String, dynamic>),
      appMeta: DistortionAppMeta.fromJson(
        json.decode(appMeta) as Map<String, dynamic>,
      ),
      summary: DistortionSummary.fromJsonWithoutConversion(
        json.decode(summary) as Map<String, dynamic>,
      ),
      scores: scoresFromJson(json.decode(scores) as Map<String, dynamic>),
      part1: part1,
      missedPart1: missedPart1,
      part2: part2
          .map(
            (step) => DistortionStep.fromJson(
              json.decode(step) as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, List<int?>> scoresFromJson(Map<String, dynamic> json) {
    return Map.fromEntries(
      json.entries.map(
        (entry) => MapEntry(entry.key, List.from(entry.value as List<dynamic>)),
      ),
    );
  }
}
