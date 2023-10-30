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

import 'package:visualr_app/common/models/coordinates.dart';
import 'package:visualr_app/common/services/parse_service.dart';
import 'package:visualr_app/contrast/models/color.dart';
import 'package:visualr_app/contrast/models/diameter.dart';
import 'package:visualr_app/contrast/models/result.dart';
import 'package:visualr_app/meta.dart';

class ContrastStep {
  final int step;
  final EyeEnum eye;
  final Diameter diameter = Diameter(outer: 90.0, inner: 54.0);
  final List<Coordinates> coordinates;
  final Color color;
  final double? contrastSensitivity;
  final bool isFake;
  ContrastResult? result;
  DateTime? createdAt;
  DateTime? answerGivenAt;

  ContrastStep({
    required this.eye,
    required this.color,
    required this.coordinates,
    required this.contrastSensitivity,
    required this.step,
    this.isFake = false,
    this.result,
    this.createdAt,
    this.answerGivenAt,
  });

  factory ContrastStep.fromJson(Map<String, dynamic> data) {
    return ContrastStep(
      eye: (data['eye'] == "left") ? EyeEnum.left : EyeEnum.right,
      color: Color.fromJson(data['color'] as Map<String, dynamic>),
      coordinates:
          ParseService.cast<List<dynamic>>(data['coordinates'], 'coordinates')
              .map(
                (coordinate) => Coordinates.fromJson(
                  ParseService.cast<Map<String, dynamic>>(
                    coordinate,
                    'coordinates',
                  ),
                ),
              )
              .toList(),
      contrastSensitivity:
          ParseService.tryCast<double>(data['contrastSensitivity']),
      result: ContrastResult.fromJson(data['result'] as Map<String, dynamic>),
      step: ParseService.cast<int>(data['step'], 'step'),
      isFake: ParseService.cast<bool>(data['isFake'], 'isFake'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        ParseService.cast<int>(data['createdAt'], 'createdAt'),
      ),
      answerGivenAt: DateTime.fromMillisecondsSinceEpoch(
        ParseService.cast<int>(data['answerGivenAt'], 'answerGivenAt'),
      ),
    );
  }

  Map<String, dynamic> toUnityJson() {
    return {
      'eye': eye.toShortString(),
      'color': color.toJson(),
      'diameter': diameter.toJson(),
      'coordinates':
          coordinates.map((coordinate) => coordinate.toJson()).toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'createdAt': createdAt!.millisecondsSinceEpoch,
      'answerGivenAt': answerGivenAt!.millisecondsSinceEpoch,
      'eye': eye.toShortString(),
      'color': color.toJson(),
      'coordinates':
          coordinates.map((coordinate) => coordinate.toJson()).toList(),
      'isFake': isFake,
      'result': result!.toJson(),
      'contrastSensitivity': contrastSensitivity,
    };
  }

  @override
  String toString({bool unity = false}) =>
      unity ? json.encode(toUnityJson()) : json.encode(toJson());
}
