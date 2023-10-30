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

import 'package:visualr_app/meta.dart';
import 'package:visualr_app/reading_speed/models/app_meta.dart';
import 'package:visualr_app/reading_speed/models/sequence.dart';
import 'package:visualr_app/reading_speed/models/step.dart';
import 'package:visualr_app/reading_speed/models/summary.dart';

import '../data.dart';

ReadingSpeedTestSequence readingSpeedTestSequence = ReadingSpeedTestSequence(
  user: user,
  summary: readingSpeedSummary,
  appMeta: appMeta,
  createdAt: createdAt,
  steps: steps,
);

ReadingSpeedEyeSummary readingSpeedEyeSummaryLeft = ReadingSpeedEyeSummary(
  startTime: Duration.zero,
  endTime: const Duration(minutes: 1),
  wordsPerMinute: 100,
  wer: 0.2,
  cer: 0.1,
);

ReadingSpeedEyeSummary readingSpeedEyeSummaryRight = ReadingSpeedEyeSummary(
  startTime: Duration.zero,
  endTime: const Duration(minutes: 2),
  wordsPerMinute: 50,
  wer: 0.25,
  cer: 0.15,
);

ReadingSpeedSummary readingSpeedSummary = ReadingSpeedSummary(
  left: readingSpeedEyeSummaryLeft,
  right: readingSpeedEyeSummaryRight,
);

ReadingSpeedAppMeta appMeta = ReadingSpeedAppMeta(
  appVersion: "1.0.3",
  buildNumber: "1",
  locale: "de",
  device: "iPhone12,1",
);

List<ReadingSpeedTestStep> steps = [
  ReadingSpeedTestStep(
    eye: EyeEnum.left,
    words: "one hundred words",
    createdAt: createdAt,
  ),
  ReadingSpeedTestStep(
    eye: EyeEnum.right,
    words: "one hundred words",
    createdAt: createdAt,
  ),
];
