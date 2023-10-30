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
import 'package:visualr_app/common/models/app_meta.dart';
import 'package:visualr_app/common/models/display_size.dart';
import 'package:visualr_app/common/models/user.dart';
import 'package:visualr_app/ipda/models/answers.dart';
import 'package:visualr_app/ipda/models/ipda.dart';
import 'package:visualr_app/objectbox.g.dart';

@Entity()
class IPDAEntity {
  @Id()
  int id;
  String user;
  String displaySize;
  String answers;
  double ipd;
  String appMeta;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  IPDAEntity({
    this.id = 0,
    required this.createdAt,
    required this.user,
    required this.displaySize,
    required this.answers,
    required this.ipd,
    required this.appMeta,
  });

  IPDA toDTO() {
    return IPDA(
      createdAt: createdAt,
      user: User.fromJson(
        json.decode(user) as Map<String, dynamic>,
      ),
      displaySize: DisplaySize.fromJson(
        json.decode(displaySize) as Map<String, dynamic>,
      ),
      answers: IPDAAnswers.fromJson(
        json.decode(answers) as Map<String, dynamic>,
      ),
      ipd: ipd,
      appMeta: AppMeta.fromJson(
        json.decode(appMeta) as Map<String, dynamic>,
      ),
    );
  }
}
