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
import 'package:visualr_app/contrast/models/test.model.dart';
import 'package:visualr_app/widgets/results/contrast.dart';

import '../../contrast/data.dart';

void main() {
  group('ContrastResultsList', () {
    late SharedPreferences prefs;
    late Widget widget;
    setUpAll(() async {
      initializeDateFormatting("de");
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });
    setUp(() async {
      widget = ChangeNotifierProvider.value(
        value: Prefs(prefs),
        child: MaterialApp(
          home: ContrastResultsList(
            columnTitles: const ["Date", "Left", "Right"],
            sequences: [ContrastTestEntity.fromDTO(test: contrastTest)],
          ),
        ),
      );
    });
    testWidgets("create a table", (widgetTester) async {
      await widgetTester.pumpWidget(widget);
      expect(find.text("Date"), findsWidgets);
      expect(find.text("Left"), findsWidgets);
      expect(find.text("Right"), findsWidgets);
    });
    testWidgets("create a row in the table for a contrast test",
        (widgetTester) async {
      await widgetTester.pumpWidget(widget);
      expect(
        find.text(contrastTest.summary.left!.avg.toString()),
        findsOneWidget,
      );
      expect(
        find.text(contrastTest.summary.right!.avg.toString()),
        findsOneWidget,
      );
    });
  });
}
