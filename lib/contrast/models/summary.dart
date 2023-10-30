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

class ContrastEyeSummary {
  final double? avg;
  final double? std;

  ContrastEyeSummary({required this.avg, required this.std});

  factory ContrastEyeSummary.fromJson(Map<String, dynamic> data) {
    return ContrastEyeSummary(
      avg: data['avg'] as double?,
      std: data['std'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {"avg": avg, "std": std};
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}

class ContrastSummary {
  final ContrastEyeSummary? left;
  final ContrastEyeSummary? right;

  ContrastSummary({required this.left, required this.right});

  factory ContrastSummary.fromJson(Map<String, dynamic> data) {
    return ContrastSummary(
      left: ContrastEyeSummary.fromJson(
        data['left'] as Map<String, dynamic>,
      ),
      right: ContrastEyeSummary.fromJson(
        data['right'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {"left": left?.toJson(), "right": right?.toJson()};
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
