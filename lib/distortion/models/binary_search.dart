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

class BinarySearch {
  final String line;
  int dotSpacingId;
  int lowerLimit;
  int upperLimit;
  BinarySearch({
    required this.line,
    this.dotSpacingId = 10,
    this.lowerLimit = 0,
    this.upperLimit = 21,
  });

  factory BinarySearch.fromJson(Map<String, dynamic> data) {
    return BinarySearch(
      line: ParseService.cast<String>(data['line'], 'line'),
      dotSpacingId:
          ParseService.cast<int>(data['dotSpacingId'], 'dotSpacingId'),
      lowerLimit: ParseService.cast<int>(data['lowerLimit'], 'lowerLimit'),
      upperLimit: ParseService.cast<int>(data['upperLimit'], 'upperLimit'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line': line,
      'dotSpacingId': dotSpacingId,
      'lowerLimit': lowerLimit,
      'upperLimit': upperLimit,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }

  bool get finished => upperLimit - lowerLimit == 1;

  @override
  bool operator ==(Object other) =>
      other is BinarySearch &&
      line == other.line &&
      dotSpacingId == other.dotSpacingId &&
      lowerLimit == other.lowerLimit &&
      upperLimit == other.upperLimit;

  @override
  int get hashCode => Object.hash(dotSpacingId, lowerLimit, upperLimit);
}
