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

class IPDAAnswers {
  List<int> raw;
  List<int> decoded;

  IPDAAnswers({
    required this.raw,
    required this.decoded,
  });

  factory IPDAAnswers.fromJson(Map<String, dynamic> data) {
    return IPDAAnswers(
      raw: ParseService.castList<int>(data['raw'], 'raw'),
      decoded: ParseService.castList<int>(data['decoded'], 'decoded'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raw': raw,
      'decoded': decoded,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
