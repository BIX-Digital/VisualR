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

class DistortionStep {
  String line;
  DateTime createdAt;
  DateTime answerGivenAt;
  int dotSpacing;
  bool? answer;

  DistortionStep({
    required this.line,
    required this.createdAt,
    required this.answerGivenAt,
    required this.dotSpacing,
    required this.answer,
  });

  factory DistortionStep.fromJson(Map<String, dynamic> data) {
    return DistortionStep(
      line: ParseService.cast<String>(data['line'], 'line'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        ParseService.cast<int>(data['createdAt'], 'createdAt'),
      ),
      answerGivenAt: DateTime.fromMillisecondsSinceEpoch(
        ParseService.cast<int>(data['answerGivenAt'], 'answerGivenAt'),
      ),
      dotSpacing: ParseService.cast<int>(data['dotSpacing'], 'dotSpacing'),
      answer: ParseService.tryCast(data['answer']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line': line,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'answerGivenAt': answerGivenAt.millisecondsSinceEpoch,
      'dotSpacing': dotSpacing,
      'answer': answer,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
