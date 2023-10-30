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
import 'package:visualr_app/reading_speed/models/app_meta.dart';
import 'package:visualr_app/reading_speed/models/sequence.dart';
import 'package:visualr_app/reading_speed/models/step.dart';
import 'package:visualr_app/reading_speed/models/summary.dart';

@Entity()
class ReadingSpeedTestSequenceEntity {
  int id;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  String user;
  String summary;
  String appMeta;
  List<String> steps;

  ReadingSpeedTestSequenceEntity({
    this.id = 0,
    required this.user,
    required this.createdAt,
    required this.summary,
    required this.appMeta,
    required this.steps,
  });

  factory ReadingSpeedTestSequenceEntity.fromDTO({
    required ReadingSpeedTestSequence sequence,
  }) {
    final ReadingSpeedTestSequenceEntity entity =
        ReadingSpeedTestSequenceEntity(
      id: sequence.id,
      createdAt: sequence.createdAt,
      user: json.encode(sequence.user.toJson()),
      summary: json.encode(sequence.summary.toJson()),
      appMeta: json.encode(sequence.appMeta.toJson()),
      steps: sequence.steps.map((step) => json.encode(step)).toList(),
    );
    return entity;
  }

  ReadingSpeedTestSequence toDTO() {
    return ReadingSpeedTestSequence(
      id: id,
      createdAt: createdAt,
      user: User.fromJson(
        json.decode(user) as Map<String, dynamic>,
      ),
      summary: ReadingSpeedSummary.fromJson(
        json.decode(summary) as Map<String, dynamic>,
      ),
      appMeta: ReadingSpeedAppMeta.fromJson(
        json.decode(appMeta) as Map<String, dynamic>,
      ),
      steps: steps
          .map(
            (step) => ReadingSpeedTestStep.fromJson(
              json.decode(step) as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
