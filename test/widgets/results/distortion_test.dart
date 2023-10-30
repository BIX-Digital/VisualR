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

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/distortion/models/test.model.dart';
import 'package:visualr_app/widgets/results/distortion.dart';

import '../../distortion/data.dart';

void main() {
  group('DistortionResultsList', () {
    late SharedPreferences prefs;
    late Widget widget;
    final List<String> columnTitles = ["Date", "Left (-/|)", "Right (-/|)"];
    setUpAll(() async {
      initializeDateFormatting("de");
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });
    setUp(() async {
      widget = ChangeNotifierProvider.value(
        value: Prefs(prefs),
        child: MaterialApp(
          home: DistortionResultsList(
            columnTitles: columnTitles,
            sequences: [DistortionTestEntity.fromDTO(test: distortionTest)],
          ),
        ),
      );
    });
    testWidgets("create a table", (widgetTester) async {
      await widgetTester.pumpWidget(widget);
      for (final String columnTitle in columnTitles) {
        expect(find.text(columnTitle), findsWidgets);
      }
    });
    testWidgets("calculates score correctly", (widgetTester) async {
      await widgetTester.pumpWidget(widget);
      expect(find.text("1.02 / 1.63"), findsNWidgets(2));
    });
  });
}
