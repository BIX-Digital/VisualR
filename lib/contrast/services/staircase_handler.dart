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

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:visualr_app/contrast/models/color.dart';
import 'package:visualr_app/contrast/models/contrast_level.dart';
import 'package:visualr_app/contrast/models/summary.dart';

class StaircaseHandler {
  int step;
  int position = 0;
  List<double> average = [];
  int numCycles = 0;
  int numIterations = 0;
  int? direction;
  late final List<ContrastLevel> contrastLevels;
  final bool darkBackground;
  final double minPercentageSeen;
  final int maxCycles;
  final int maxIterations;
  final String device;
  StaircaseHandler({
    this.darkBackground = true,
    this.minPercentageSeen = 0.5,
    this.step = 1,
    this.maxCycles = 8,
    this.maxIterations = 30,
    this.device = 'iPhone14,5',
  }) {
    contrastLevels = listOfContrastLevels
        .where(
          (contrastLevel) =>
              contrastLevel.device == device &&
              contrastLevel.darkBackground == darkBackground,
        )
        .toList();
  }

  bool get isFinished =>
      !(numCycles < maxCycles && numIterations < maxIterations);

  double get contrast => contrastLevels[position].contrast;

  Color getNextColor(double percentageSeen) {
    numIterations++;
    return numIterations == 1
        ? contrastLevels[position].color
        : iteration(percentageSeen);
  }

  Color iteration(double percentageSeen) {
    final int? oldDirection = direction;
    direction = percentageSeen > minPercentageSeen ? 1 : -1;
    if (oldDirection != null && direction != oldDirection) {
      average.add(contrastLevels[position].contrast);
      numCycles++;
    }
    position += direction! * step;

    // Edge cases:
    // check if out of scale - in this case repeat the last possible value
    // and store the values for later average
    if (position < 0) {
      position = 0;
      average.add(contrastLevels[position].contrast);
      numCycles++;
    }
    if (position >= contrastLevels.length) {
      position = contrastLevels.length - 1;
      average.add(contrastLevels[position].contrast);
      numCycles++;
    }
    return contrastLevels[position].color;
  }

  ContrastEyeSummary getSummary({int start = 2, int? end}) {
    final averageSublist = average.sublist(start, end);
    final double avg = averageSublist.average;
    final double variance = averageSublist.map((x) => pow(x - avg, 2)).average;
    final double std = sqrt(variance) / sqrt(averageSublist.length);
    return ContrastEyeSummary(
      avg: double.parse(avg.toStringAsFixed(3)),
      std: double.parse(std.toStringAsFixed(3)),
    );
  }
}
