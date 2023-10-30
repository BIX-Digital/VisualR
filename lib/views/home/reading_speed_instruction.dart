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
import 'package:provider/provider.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/routes/router.gr.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/theme/themes.dart';
import 'package:visualr_app/views/onboarding/onboarding_layout.dart';

@RoutePage()
class ReadingSpeedInstructionsPage extends StatelessWidget {
  final bool showInstructions;
  const ReadingSpeedInstructionsPage({
    super.key,
    required this.showInstructions,
  });

  void _closeInstructions(
    BuildContext context,
    Prefs prefs,
    Object? completed,
  ) {
    AutoRouter.of(context).pop(completed);
  }

  void _openReadingSpeedTest(BuildContext context, Prefs prefs) {
    AutoRouter.of(context)
        .push(UnityReadingSpeedRoute(showInstructions: showInstructions))
        .then((completed) {
      _closeInstructions(context, prefs, completed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        backgroundColor: const AppColors().transparent,
        elevation: 0.0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
      ),
      body: OnboardingLayout(
        title: AppLocalizations.of(context)!.common_task,
        body: Container(
          alignment: Alignment.topLeft,
          child: Text(
            AppLocalizations.of(context)!.reading_speed_instructions,
            style: AppThemes().body.merge(AppThemes().spacedLetters),
          ),
        ),
        button: Consumer<Prefs>(
          builder: (context, prefs, child) => ElevatedButton(
            onPressed: () => _openReadingSpeedTest(context, prefs),
            child: Text(
              AppLocalizations.of(context)!.common_understood,
              style: AppThemes().body.merge(AppThemes().spacedLetters),
            ),
          ),
        ),
      ),
    );
  }
}
