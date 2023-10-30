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

class ReadingSpeedEyeSummary {
  final Duration startTime;
  final Duration endTime;
  final double wordsPerMinute;
  final double wer;
  final double cer;

  ReadingSpeedEyeSummary({
    required this.startTime,
    required this.endTime,
    required this.wordsPerMinute,
    required this.wer,
    required this.cer,
  });

  factory ReadingSpeedEyeSummary.fromJson(Map<String, dynamic> data) {
    return ReadingSpeedEyeSummary(
      startTime: ParseService.duration(data['start_time'] as String),
      endTime: ParseService.duration(data['end_time'] as String),
      wordsPerMinute: data['wordsPerMinute'] as double,
      wer: data['wer'] as double,
      cer: data['cer'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "start_time": startTime.toString(),
      "end_time": endTime.toString(),
      "wordsPerMinute": wordsPerMinute,
      "wer": wer,
      "cer": cer,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}

class ReadingSpeedSummary {
  final ReadingSpeedEyeSummary? left;
  final ReadingSpeedEyeSummary? right;

  ReadingSpeedSummary({required this.left, required this.right});

  factory ReadingSpeedSummary.fromJson(Map<String, dynamic> data) {
    return ReadingSpeedSummary(
      left: ReadingSpeedEyeSummary.fromJson(
        data['left'] as Map<String, dynamic>,
      ),
      right: ReadingSpeedEyeSummary.fromJson(
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
