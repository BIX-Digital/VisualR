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

class Color {
  final int r;
  final int g;
  final int b;

  const Color({required this.r, required this.g, required this.b});

  factory Color.fromJson(Map<String, dynamic> data) {
    return Color(
      r: data['r'] as int,
      g: data['g'] as int,
      b: data['b'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {"r": r, "g": g, "b": b};
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
