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

import 'package:visualr_app/common.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/distortion/models/summary.dart';
import 'package:visualr_app/distortion/models/test.model.dart';
import 'package:visualr_app/theme/themes.dart';
import 'package:visualr_app/widgets/results/results_list.dart';

class AverageSummary {
  late int leftHorizontal;
  late int leftVertical;
  late int rightHorizontal;
  late int rightVertical;
  AverageSummary({required DistortionSummary summary}) {
    leftHorizontal = summary.left.h.isEmpty
        ? 0
        : summary.left.h.reduce((a, b) => a + b) ~/ 3;
    leftVertical = summary.left.h.isEmpty
        ? 0
        : summary.left.v.reduce((a, b) => a + b) ~/ 3;
    rightHorizontal = summary.left.h.isEmpty
        ? 0
        : summary.right.h.reduce((a, b) => a + b) ~/ 3;
    rightVertical = summary.left.h.isEmpty
        ? 0
        : summary.right.v.reduce((a, b) => a + b) ~/ 3;
  }
}

class DistortionResultsList extends ResultsList<DistortionTestEntity> {
  const DistortionResultsList({
    super.key,
    required super.columnTitles,
    required super.sequences,
  });

  String getDisplayValue(int value) {
    return (value / 60).toStringAsFixed(2);
  }

  @override
  List<DataRow> getRows(
    List<DistortionTestEntity> sequences,
    Prefs prefs,
  ) =>
      sequences
          .where((sequence) => sequence.toDTO().user.id == prefs.user.id)
          .map((sequence) {
        final averageSummary =
            AverageSummary(summary: sequence.toDTO().summary);
        final List<Widget> cells = [
          Text(
            formatDate(sequence.createdAt),
            style: AppThemes().small.merge(AppThemes().grey),
          ),
          Text(
            '${getDisplayValue(averageSummary.leftHorizontal)} / ${getDisplayValue(averageSummary.leftVertical)}',
            style: AppThemes().small,
          ),
          Text(
            '${getDisplayValue(averageSummary.rightHorizontal)} / ${getDisplayValue(averageSummary.rightVertical)}',
            style: AppThemes().small,
          ),
        ];
        return DataRow(cells: getCells(cells));
      }).toList();
}
