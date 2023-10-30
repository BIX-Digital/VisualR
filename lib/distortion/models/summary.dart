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
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:visualr_app/common/services/parse_service.dart';
import 'package:visualr_app/distortion/models/eye_summary.dart';

class DistortionSummary {
  final DistortionEyeSummary left;
  final DistortionEyeSummary right;
  DistortionSummary({
    required this.left,
    required this.right,
  });

  factory DistortionSummary.fromScores(Map<String, double> scores) {
    List<double> maxBins(List<double> listScores) {
      if (listScores.length == 9) {
        return [
          for (var i = 0; i < 3; i++)
            listScores.sublist(3 * i, 3 + 3 * i).reduce(max),
        ];
      } else {
        return [];
      }
    }

    List<double> getScoresInBin(String binIdentifier) {
      return scores.entries
          .sortedBy((entry) => entry.key)
          .where((entry) => entry.key.contains(binIdentifier))
          .map((entry) => entry.value)
          .toList();
    }

    return DistortionSummary(
      left: DistortionEyeSummary(
        h: maxBins(getScoresInBin('_h_l')),
        v: maxBins(getScoresInBin('_v_l')),
      ),
      right: DistortionEyeSummary(
        h: maxBins(getScoresInBin('_h_r')),
        v: maxBins(getScoresInBin('_v_r')),
      ),
    );
  }

  factory DistortionSummary.fromJson(Map<String, dynamic> data) {
    return DistortionSummary(
      left: DistortionEyeSummary.fromJson(
        ParseService.cast<Map<String, dynamic>>(data['left'], 'left'),
      ),
      right: DistortionEyeSummary.fromJson(
        ParseService.cast<Map<String, dynamic>>(data['right'], 'right'),
      ),
    );
  }

  factory DistortionSummary.fromJsonWithoutConversion(
    Map<String, dynamic> data,
  ) {
    return DistortionSummary(
      left: DistortionEyeSummary.fromJsonWithoutConversion(
        ParseService.cast<Map<String, dynamic>>(data['left'], 'left'),
      ),
      right: DistortionEyeSummary.fromJsonWithoutConversion(
        ParseService.cast<Map<String, dynamic>>(data['right'], 'right'),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'left': left.toJson(),
      'right': right.toJson(),
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
