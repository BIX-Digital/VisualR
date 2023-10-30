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

import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/common/models/export_data.dart';
import 'package:visualr_app/common/models/user.dart';
import 'package:visualr_app/common/services/share_service.dart';
import 'package:visualr_app/contrast/models/test.dart';
import 'package:visualr_app/contrast/models/test.model.dart';
import 'package:visualr_app/distortion/models/test.dart';
import 'package:visualr_app/distortion/models/test.model.dart';
import 'package:visualr_app/ipda/models/ipda.dart';
import 'package:visualr_app/ipda/models/ipda.model.dart';
import 'package:visualr_app/main.dart';
import 'package:visualr_app/reading_speed/models/sequence.dart';
import 'package:visualr_app/reading_speed/models/sequence.model.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/theme/themes.dart';
import 'package:visualr_app/widgets/page_layout.dart';
import 'package:visualr_app/widgets/results/contrast.dart';
import 'package:visualr_app/widgets/results/distortion.dart';
import 'package:visualr_app/widgets/results/reading_speed.dart';

@RoutePage()
class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage>
    with TickerProviderStateMixin, AutoRouteAwareStateMixin<ResultsPage> {
  late final TabController _tabController;
  List<ContrastTestEntity> _contrastDarkEntities = [];
  List<ContrastTestEntity> _contrastLightEntities = [];
  List<IPDAEntity> _ipdaEntities = [];
  List<DistortionTestEntity> _distortionEntities = [];
  List<ReadingSpeedTestSequenceEntity> _readingSpeedEntities = [];
  final ShareService _shareService = ShareService();

  @override
  void initState() {
    super.initState();
    _getEntities();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeTabRoute(TabPageRoute previousRoute) {
    _getEntities();
  }

  void _getEntities() {
    setState(() {
      _ipdaEntities = objectBox.ipda.getAll();
      _contrastDarkEntities = objectBox.contrast.getAllLightOrDark(
        isDark: true,
      );
      _contrastLightEntities = objectBox.contrast.getAllLightOrDark(
        isDark: false,
      );
      _distortionEntities = objectBox.distortion.getAll();
      _readingSpeedEntities = objectBox.readingSpeed.getAll();
    });
  }

  void _exportResults() {
    final List<IPDA> ipdas =
        _ipdaEntities.map((entity) => entity.toDTO()).toList();
    final List<ContrastTest> contrastDarkSequences =
        _contrastDarkEntities.asMap().entries.map((entry) {
      // update the entities ID to be counting only dark contrast tests
      entry.value.id = entry.key + 1;
      return entry.value.toDTO();
    }).toList();
    final List<ContrastTest> contrastLightSequences =
        _contrastLightEntities.asMap().entries.map((entry) {
      // update the entities ID to be counting only light contrast tests
      entry.value.id = entry.key + 1;
      return entry.value.toDTO();
    }).toList();
    final List<ReadingSpeedTestSequence> readingSpeedSequences =
        _readingSpeedEntities.map((entity) => entity.toDTO()).toList();
    final List<DistortionTest> distortionSequences =
        _distortionEntities.map((entity) => entity.toDTO()).toList();
    final ExportData exportData = ExportData(
      ipda: ipdas,
      contrastDark: contrastDarkSequences,
      contrastLight: contrastLightSequences,
      distortion: distortionSequences,
      readingSpeed: readingSpeedSequences,
    );
    final User firstUser = ipdas.first.user;
    _shareService.onShare(
      json.encode(exportData.toJson()),
      _getExportFileName(firstUser),
    );
  }

  String _getExportFileName(User user) {
    final String exportId = user.id.substring(0, 6);
    final String formattedDate = _getCurrentDateTime();
    return "export_${exportId}_$formattedDate.json";
  }

  String _getCurrentDateTime() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat.yMd("de").add_Hms();
    return formatter
        .format(now)
        .replaceAll(" ", "_")
        .replaceAll(".", "_")
        .replaceAll(":", "_");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageLayout(
          padding: 0,
          heading: TabBar(
            labelStyle: AppThemes()
                .body
                .merge(AppThemes().bold)
                .merge(AppThemes().sora),
            labelColor: const AppColors().black,
            unselectedLabelColor: const AppColors().grey,
            controller: _tabController,
            isScrollable: true,
            indicatorColor: const AppColors().black,
            labelPadding: const EdgeInsets.all(8.0),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Text(AppLocalizations.of(context)!.visualTests_distortion),
              Text(AppLocalizations.of(context)!.visualTests_contrast_dark),
              Text(AppLocalizations.of(context)!.visualTests_contrast_light),
              Text(AppLocalizations.of(context)!.visualTests_speed),
            ],
          ),
          content: TabBarView(
            controller: _tabController,
            children: [
              DistortionResultsList(
                columnTitles: [
                  AppLocalizations.of(context)!.common_dateTime,
                  '${AppLocalizations.of(context)!.common_left} (-/|)',
                  '${AppLocalizations.of(context)!.common_right} (-/|)',
                ],
                sequences: _distortionEntities,
              ),
              ContrastResultsList(
                columnTitles: [
                  AppLocalizations.of(context)!.common_dateTime,
                  AppLocalizations.of(context)!.common_left,
                  AppLocalizations.of(context)!.common_right,
                ],
                sequences: _contrastDarkEntities,
              ),
              ContrastResultsList(
                columnTitles: [
                  AppLocalizations.of(context)!.common_dateTime,
                  AppLocalizations.of(context)!.common_left,
                  AppLocalizations.of(context)!.common_right,
                ],
                sequences: _contrastLightEntities,
              ),
              ReadingSpeedResultsList(
                columnTitles: [
                  AppLocalizations.of(context)!.common_dateTime,
                  AppLocalizations.of(context)!.common_left,
                  AppLocalizations.of(context)!.common_right,
                ],
                sequences: _readingSpeedEntities,
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 44.0),
            child: ElevatedButton(
              onPressed: _exportResults,
              child: Text(
                AppLocalizations.of(context)!.export,
                style: AppThemes().body.merge(AppThemes().spacedLetters),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
