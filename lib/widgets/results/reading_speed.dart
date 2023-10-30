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
import 'package:visualr_app/reading_speed/models/sequence.model.dart';
import 'package:visualr_app/theme/themes.dart';
import 'package:visualr_app/widgets/results/results_list.dart';

class ReadingSpeedResultsList
    extends ResultsList<ReadingSpeedTestSequenceEntity> {
  const ReadingSpeedResultsList({
    super.key,
    required super.columnTitles,
    required super.sequences,
  });

  @override
  List<DataRow> getRows(
    List<ReadingSpeedTestSequenceEntity> sequences,
    Prefs prefs,
  ) =>
      sequences
          .where((sequence) => sequence.toDTO().user.id == prefs.user.id)
          .map(
        (sequence) {
          final List<Widget> cells = [
            Text(
              formatDate(sequence.createdAt),
              style: AppThemes().small.merge(AppThemes().grey),
            ),
            Text(
              sequence.toDTO().summary.left!.wordsPerMinute.toStringAsFixed(2),
              style: AppThemes().small,
            ),
            Text(
              sequence.toDTO().summary.right!.wordsPerMinute.toStringAsFixed(2),
              style: AppThemes().small,
            ),
          ];
          return DataRow(cells: getCells(cells));
        },
      ).toList();
}
