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

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/theme/themes.dart';

abstract class ResultsList<T> extends StatelessWidget {
  final List<T> sequences;
  final List<String> columnTitles;
  const ResultsList({
    super.key,
    required this.columnTitles,
    required this.sequences,
  });

  String formatDate(DateTime dateTime, [String locale = 'de']) {
    final DateFormat formatter = DateFormat.yMd(locale).add_Hm();
    return formatter.format(dateTime);
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map(
        (column) => DataColumn(
          label: Text(
            column,
            style: AppThemes().small.merge(AppThemes().bold),
          ),
        ),
      )
      .toList();

  List<DataRow> getRows(
    List<T> sequences,
    Prefs prefs,
  ) =>
      throw UnimplementedError('getRows() has not been implemented.');

  List<DataCell> getCells(List<Widget> cells) => cells
      .map(
        (cell) => DataCell(cell),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const AppColors().background,
          const AppColors().transparent,
        ],
        stops: const [2 / 3, 0.9],
      ).createShader(bounds),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // In order for the table header to stick we need to create two DataTables.
        // One with only the columns/headers that stick and a scrollable DataTable
        // that only has the rows to be displayed. As columns is not allowed to
        // be empty we need to add 3 DataColumns and set the height of the
        // headingRow to 0.0
        children: [
          DataTable(
            columnSpacing: 28.0,
            columns: getColumns(columnTitles),
            rows: const [],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Consumer<Prefs>(
                    builder: (context, prefs, child) => DataTable(
                      columnSpacing: 28.0,
                      columns: getColumns(columnTitles),
                      rows: getRows(sequences, prefs),
                      headingRowHeight: 0.0,
                    ),
                  ),
                  SizedBox.fromSize(
                    size: const Size(0, 200),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
