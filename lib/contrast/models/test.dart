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
import 'package:visualr_app/contrast/models/app_meta.dart';
import 'package:visualr_app/contrast/models/color.dart';
import 'package:visualr_app/contrast/models/step.dart';
import 'package:visualr_app/contrast/models/summary.dart';

class ContrastTest {
  DateTime createdAt;
  User user;
  Color backgroundColor;
  ContrastSummary summary;
  ContrastAppMeta appMeta;
  List<ContrastStep> steps = [];
  int id;
  bool isDark;

  ContrastTest({
    required this.user,
    required this.backgroundColor,
    required this.summary,
    required this.appMeta,
    required this.steps,
    required this.createdAt,
    required this.isDark,
    this.id = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'user': user.toJson(),
      'backgroundColor': backgroundColor.toJson(),
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
