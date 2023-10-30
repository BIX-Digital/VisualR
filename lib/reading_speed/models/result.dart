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

import 'package:visualr_app/common/services/parse_service.dart';
import 'package:visualr_app/meta.dart';

class ReadingSpeedResult {
  final String words;
  final Duration startTime;
  final Duration endTime;
  final double wordErrorRate;
  final double characterErrorRate;
  final EyeEnum eye;

  ReadingSpeedResult({
    required this.words,
    required this.startTime,
    required this.endTime,
    required this.wordErrorRate,
    required this.characterErrorRate,
    required this.eye,
  });

  Map<String, dynamic> toJson() {
    return {
      'words': words,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'wordErrorRate': wordErrorRate,
      'characterErrorRate': characterErrorRate,
      'eye': eye.toShortString(),
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }

  factory ReadingSpeedResult.fromJson(Map<String, dynamic> data) {
    return ReadingSpeedResult(
      words: data['words'] as String,
      startTime: ParseService.duration(data['startTime'] as String),
      endTime: ParseService.duration(data['endTime'] as String),
      wordErrorRate: data['wordErrorRate'] as double,
      characterErrorRate: data['characterErrorRate'] as double,
      eye: (data['eye'] == "left") ? EyeEnum.left : EyeEnum.right,
    );
  }
}
