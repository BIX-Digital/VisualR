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

import 'package:flutter/foundation.dart';
import 'package:visualr_app/common/services/parse_service.dart';
import 'package:visualr_app/distortion/models/line.dart';

class DistortionEyeSummary {
  final List<double> h;
  final List<double> v;
  DistortionEyeSummary({
    required this.h,
    required this.v,
  });

  factory DistortionEyeSummary.fromJson(Map<String, dynamic> data) {
    return DistortionEyeSummary(
      h: ParseService.cast<List<dynamic>>(data['h'], 'h')
          .map((e) => ParseService.cast<double>(e, 'value in h'))
          .map((e) {
        final double dotSpacingInArcmins = getDotSpacing(e);
        return dotSpacingInArcmins == 6.0 ? 0.0 : dotSpacingInArcmins;
      }).toList(),
      v: ParseService.cast<List<dynamic>>(data['v'], 'v')
          .map((e) => ParseService.cast<double>(e, 'value in v'))
          .map((e) {
        final double dotSpacingInArcmins = getDotSpacing(e);
        return dotSpacingInArcmins == 6.0 ? 0.0 : dotSpacingInArcmins;
      }).toList(),
    );
  }

  factory DistortionEyeSummary.fromJsonWithoutConversion(
    Map<String, dynamic> data,
  ) {
    return DistortionEyeSummary(
      h: ParseService.cast<List<dynamic>>(data['h'], 'h')
          .map((e) => ParseService.cast<double>(e, 'value in h'))
          .toList(),
      v: ParseService.cast<List<dynamic>>(data['v'], 'v')
          .map((e) => ParseService.cast<double>(e, 'value in v'))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'h': h,
      'v': v,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }

  @override
  bool operator ==(Object other) =>
      other is DistortionEyeSummary &&
      listEquals(h, other.h) &&
      listEquals(v, other.v);

  @override
  int get hashCode => Object.hash(h, v);
}
