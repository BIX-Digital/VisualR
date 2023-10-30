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

import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/routes/router.gr.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/theme/themes.dart';
import 'package:visualr_app/views/home/results.dart';
import 'package:visualr_app/views/home/test_selection.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const AppColors().transparent,
        elevation: 0.0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: (MediaQuery.of(context).size.width -
                      MediaQuery.of(context).size.width / 1.4) /
                  2,
            ),
            child: IconButton(
              onPressed: () =>
                  AutoRouter.of(context).push(const SettingsRoute()),
              icon: Icon(
                Icons.settings,
                color: const AppColors().black,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelStyle: AppThemes()
                .title
                .merge(AppThemes().bold)
                .merge(AppThemes().sora),
            labelColor: const AppColors().black,
            unselectedLabelColor: const AppColors().grey,
            indicatorColor: const AppColors().black,
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            tabs: [
              Text(AppLocalizations.of(context)!.visualTests),
              Text(AppLocalizations.of(context)!.results),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                TestSelectionPage(),
                ResultsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
