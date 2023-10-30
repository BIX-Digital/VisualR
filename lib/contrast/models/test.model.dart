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
import 'package:visualr_app/contrast/models/app_meta.dart';
import 'package:visualr_app/contrast/models/color.dart';
import 'package:visualr_app/contrast/models/step.dart';
import 'package:visualr_app/contrast/models/summary.dart';
import 'package:visualr_app/contrast/models/test.dart';
import 'package:visualr_app/objectbox.g.dart';

@Entity()
class ContrastTestEntity {
  @Id()
  int id;
  @Property(type: PropertyType.date)
  DateTime createdAt;

  String user;
  String backgroundColor;
  String summary;
  String appMeta;
  List<String> steps;
  bool isDark;

  ContrastTestEntity({
    this.id = 0,
    required this.user,
    required this.backgroundColor,
    required this.createdAt,
    required this.summary,
    required this.appMeta,
    required this.steps,
    required this.isDark,
  });

  factory ContrastTestEntity.fromDTO({
    required ContrastTest test,
  }) {
    return ContrastTestEntity(
      id: test.id,
      createdAt: test.createdAt,
      user: json.encode(test.user.toJson()),
      backgroundColor: json.encode(test.backgroundColor.toJson()),
      summary: json.encode(test.summary.toJson()),
      appMeta: json.encode(test.appMeta.toJson()),
      steps: test.steps.map((step) => json.encode(step.toJson())).toList(),
      isDark: test.isDark,
    );
  }

  ContrastTest toDTO() {
    return ContrastTest(
      id: id,
      createdAt: createdAt,
      user: User.fromJson(
        json.decode(user) as Map<String, dynamic>,
      ),
      backgroundColor: Color.fromJson(
        json.decode(backgroundColor) as Map<String, dynamic>,
      ),
      summary: ContrastSummary.fromJson(
        json.decode(summary) as Map<String, dynamic>,
      ),
      appMeta: ContrastAppMeta.fromJson(
        json.decode(appMeta) as Map<String, dynamic>,
      ),
      steps: steps
          .map(
            (step) => ContrastStep.fromJson(
              json.decode(step) as Map<String, dynamic>,
            ),
          )
          .toList(),
      isDark: isDark,
    );
  }
}
