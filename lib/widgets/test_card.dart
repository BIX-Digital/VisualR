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
import 'package:visualr_app/main.dart';
import 'package:visualr_app/meta.dart';
import 'package:visualr_app/routes/router.gr.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/theme/themes.dart';
import 'package:visualr_app/views/unity/unity_view.dart';
import 'package:visualr_app/widgets/toast_helper.dart';

class TestSelectionCard extends StatelessWidget {
  final String testName;
  final Widget? child;
  final UnityView test;
  final Color color;
  const TestSelectionCard({
    super.key,
    this.child,
    required this.color,
    required this.test,
    required this.testName,
  });

  bool hasPreviouslyBeenCompleted(Prefs prefs, UnityView test) {
    return prefs.finishedTests.contains(test.toShortString());
  }

  void _deleteTestSequence(
    BuildContext context,
    UnityView view,
  ) {
    switch (view) {
      case UnityView.distortion:
        objectBox.distortion.delete();
      case UnityView.contrastDark:
        objectBox.contrast.delete();
      case UnityView.contrastLight:
        objectBox.contrast.delete();
      case UnityView.readingSpeed:
        objectBox.readingSpeed.delete();
      default:
        break;
    }
    AutoRouter.of(context).pop().then(
          (_) => createBasicToast(
            message:
                AppLocalizations.of(context)!.visualTests_completed_deleted,
            icon: Icons.check,
          ).show(context),
        );
  }

  void _showSuccessModal(BuildContext parentContext, UnityView view) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.visualTests_completed_title,
          style: AppThemes().body.merge(AppThemes().bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context)!.visualTests_completed_content,
            style: AppThemes().body,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _deleteTestSequence(context, view),
            child: Text(
              AppLocalizations.of(context)!.common_delete,
              style: AppThemes()
                  .body
                  .merge(AppThemes().bold)
                  .merge(AppThemes().error),
            ),
          ),
          TextButton(
            onPressed: () => AutoRouter.of(context).pop().then(
                  (_) => createBasicToast(
                    message: AppLocalizations.of(parentContext)!
                        .visualTests_completed_saved,
                    icon: Icons.check,
                  ).show(parentContext),
                ),
            child: Text(
              AppLocalizations.of(context)!.common_save,
              style: AppThemes().body.merge(AppThemes().bold),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );
  }

  void _showErrorModal(BuildContext parentContext, UnityView view) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.visualTests_error_title,
          style: AppThemes().body.merge(AppThemes().bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context)!.visualTests_error_content,
            style: AppThemes().body,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AutoRouter.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.common_cancel_short,
              style: AppThemes()
                  .body
                  .merge(AppThemes().bold)
                  .merge(AppThemes().error),
            ),
          ),
          TextButton(
            onPressed: () => AutoRouter.of(context)
                .pop()
                .then((_) => _openTest(parentContext, false)),
            child: Text(
              AppLocalizations.of(context)!.common_repeat,
              style: AppThemes().body.merge(AppThemes().bold),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );
  }

  void _openTest(BuildContext context, bool showInstructions) {
    PageRouteInfo route;
    switch (test) {
      case UnityView.distortion:
        route = UnityDistortionRoute(
          showInstructions: showInstructions,
        );
      case UnityView.contrastDark:
        route = UnityContrastRoute(
          showInstructions: showInstructions,
          unityView: UnityView.contrastDark,
        );
      case UnityView.contrastLight:
        route = UnityContrastRoute(
          showInstructions: showInstructions,
          unityView: UnityView.contrastLight,
        );
      case UnityView.readingSpeed:
        route = showInstructions
            ? ReadingSpeedInstructionsRoute(
                showInstructions: showInstructions,
              )
            : UnityReadingSpeedRoute(
                showInstructions: showInstructions,
              ) as PageRouteInfo;
      default:
        route = UnityDistortionRoute(
          showInstructions: showInstructions,
        );
    }
    AutoRouter.of(context).push(UnityRouter(children: [route])).then(
      (completedTest) {
        if ((completedTest as UnityCloseMessage?)!.status ==
            UnityTestState.success) {
          _showSuccessModal(context, completedTest!.view);
        } else if (completedTest!.status == UnityTestState.error) {
          _showErrorModal(context, completedTest.view);
        }
      },
    );
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Prefs>(
      builder: (context, prefs, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1 / 1.4,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const AppColors().black.withOpacity(0.25),
                      blurRadius: 50.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Card(
                        color: color,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                        ),
                        child: Align(
                          child: this.child,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                            ),
                            color: const AppColors().white,
                          ),
                          child: TextButton(
                            onPressed: hasPreviouslyBeenCompleted(prefs, test)
                                ? () => _openTest(context, false)
                                : () => _openTest(context, true),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .visualTests_startTest,
                              style: AppThemes()
                                  .body
                                  .merge(AppThemes().bold)
                                  .merge(AppThemes().spacedLetters),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: SizedBox(
                  height: 64.0,
                  child: hasPreviouslyBeenCompleted(prefs, test)
                      ? TextButton(
                          onPressed: () => _openTest(context, true),
                          child: Text(
                            AppLocalizations.of(context)!
                                .visualTests_instructions,
                            style: AppThemes()
                                .body
                                .merge(AppThemes().spacedLetters),
                          ),
                        )
                      : Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
