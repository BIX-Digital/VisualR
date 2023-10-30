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

class DisplaySize {
  double height;
  double width;
  double dpi;

  DisplaySize({
    required this.height,
    required this.width,
    required this.dpi,
  });

  factory DisplaySize.fromJson(Map<String, dynamic> data) {
    return DisplaySize(
      height: ParseService.cast<double>(data['height'], 'height'),
      width: ParseService.cast<double>(data['width'], 'width'),
      dpi: ParseService.cast<double>(data['dpi'], 'dpi'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'width': width,
      'dpi': dpi,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
