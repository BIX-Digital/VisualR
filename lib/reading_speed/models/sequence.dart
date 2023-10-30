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
import 'package:visualr_app/reading_speed/models/app_meta.dart';
import 'package:visualr_app/reading_speed/models/step.dart';
import 'package:visualr_app/reading_speed/models/summary.dart';

class ReadingSpeedTestSequence {
  DateTime createdAt;
  User user;
  ReadingSpeedSummary summary;
  ReadingSpeedAppMeta appMeta;
  int id;
  List<ReadingSpeedTestStep> steps;

  ReadingSpeedTestSequence({
    required this.user,
    required this.summary,
    required this.appMeta,
    required this.createdAt,
    required this.steps,
    this.id = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'user': user.toJson(),
      'summary': summary.toJson(),
      'appMeta': appMeta.toJson(),
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
