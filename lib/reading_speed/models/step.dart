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
import 'package:visualr_app/meta.dart';
import 'package:visualr_app/reading_speed/models/result.dart';
import 'package:whisper_dart/scheme/scheme.dart';

class ReadingSpeedTestStep {
  final EyeEnum eye;
  final String words;
  ReadingSpeedResult? result;
  final DateTime createdAt;

  ReadingSpeedTestStep({
    required this.eye,
    required this.words,
    required this.createdAt,
  });

  factory ReadingSpeedTestStep.fromJson(Map<String, dynamic> data) {
    return ReadingSpeedTestStep(
      eye: EyeEnum.values[EyeEnum.values.indexWhere(
        (eye) =>
            eye.toShortString() ==
            ParseService.cast<String>(data['eye'], 'eye'),
      )],
      words: ParseService.cast<String>(data['words'], 'words'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        ParseService.cast<int>(data['createdAt'], 'createdAt'),
      ),
    );
  }

  Map<String, dynamic> toUnityJson() {
    return {
      'eye': eye.toShortString(),
      'words': words,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.millisecondsSinceEpoch,
      'eye': eye.toShortString(),
      'words': words,
    };
  }

  @override
  String toString({bool unity = false}) =>
      unity ? json.encode(toUnityJson()) : json.encode(toJson());
}

class ReadingSpeedWhisperResult {
  final String type;
  final List<WhisperSegment>? segments;
  final String text;
  final String? sentText;

  ReadingSpeedWhisperResult({
    required this.type,
    required this.segments,
    required this.text,
    required this.sentText,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'segments': segments,
      'text': text,
      'sentText': sentText,
    };
  }

  factory ReadingSpeedWhisperResult.fromJson(Map<String, dynamic> data) {
    final List? list =
        (data["segments"] != null) ? data["segments"] as List : null;
    if (list != null) {
      final List<WhisperSegment> segments = list
          .map((i) => WhisperSegment.fromJson(i as Map<String, dynamic>))
          .toList();
      return ReadingSpeedWhisperResult(
        type: data["@type"] as String,
        segments: segments,
        text: data["text"] as String,
        sentText: null,
      );
    } else {
      return ReadingSpeedWhisperResult(
        type: data["@type"] as String,
        segments: null,
        text: data["text"] as String,
        sentText: null,
      );
    }
  }
}

class WhisperResultCombined {
  final WhisperResponse result;

  WhisperResultCombined({
    required this.result,
  });
}

class WhisperSegment {
  final String t0;
  final String t1;
  final String text;

  WhisperSegment({
    required this.t0,
    required this.t1,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {'t0': t0, 't1': t1, 'text': text};
  }

  factory WhisperSegment.fromJson(Map<String, dynamic> data) {
    return WhisperSegment(
      t0: data["t0"] as String,
      t1: data["t1"] as String,
      text: data["text"] as String,
    );
  }
}
