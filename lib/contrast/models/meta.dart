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

import 'package:visualr_app/contrast/models/color.dart';

class ContrastMeta {
  final int nIter;
  final int nCycles;
  final int direction;
  final List<int> numSeen;
  final List<int> numDisplayed;
  final int? position;
  final List<double> average;

  ContrastMeta({
    required this.nIter,
    required this.nCycles,
    required this.direction,
    required this.numSeen,
    required this.numDisplayed,
    required this.position,
    required this.average,
  });

  Map<String, dynamic> toJson() {
    return {
      "nIter": nIter,
      "nCycles": nCycles,
      "direction": direction,
      "numSeen": numSeen,
      "numDisplayed": numDisplayed,
      "position": position,
      "average": average,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }

  factory ContrastMeta.fromJson(Map<String, dynamic> data) {
    return ContrastMeta(
      nIter: data['nIter'] as int,
      nCycles: data['nCycles'] as int,
      direction: data['direction'] as int,
      numSeen: List<int>.from(data['numSeen'] as Iterable),
      numDisplayed: List<int>.from(data['numDisplayed'] as Iterable),
      position: data['position'] as int?,
      average: List<double>.from(data['average'] as Iterable),
    );
  }
}

class Meta {
  final Color backgroundColor;
  final ContrastMeta left;
  final ContrastMeta right;

  Meta({
    required this.backgroundColor,
    required this.left,
    required this.right,
  });

  Map<String, dynamic> toJson() {
    return {
      "backgroundColor": backgroundColor.toJson(),
      "left": left.toJson(),
      "right": right.toJson(),
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }

  factory Meta.fromJson(Map<String, dynamic> data) {
    return Meta(
      backgroundColor: Color.fromJson(
        data['backgroundColor'] as Map<String, dynamic>,
      ),
      left: ContrastMeta.fromJson(
        data['left'] as Map<String, dynamic>,
      ),
      right: ContrastMeta.fromJson(
        data['right'] as Map<String, dynamic>,
      ),
    );
  }
}
