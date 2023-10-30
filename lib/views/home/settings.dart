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
import 'package:visualr_app/widgets/settings_tile.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _clearSharedPreferences(BuildContext context, Prefs prefs) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.reset_title,
          style: AppThemes().body.merge(AppThemes().bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.reset_body,
          style: AppThemes().body,
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              AutoRouter.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.common_cancel_short,
              style: AppThemes()
                  .body
                  .merge(AppThemes().bold)
                  .merge(AppThemes().spacedLetters),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              prefs.clear().then((_) {
                AutoRouter.of(context).pop();
                AutoRouter.of(context).replace(
                  const OnboardingRouter(
                    children: [OnboardingRoute()],
                  ),
                );
              });
            },
            child: Text(
              AppLocalizations.of(context)!.reset,
              style: AppThemes()
                  .body
                  .merge(AppThemes().bold)
                  .merge(AppThemes().error)
                  .merge(AppThemes().spacedLetters),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const AppColors().transparent,
        elevation: 0.0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: IconButton(
              onPressed: () => AutoRouter.of(context).pop(),
              icon: Icon(
                Icons.close,
                color: const AppColors().black,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.settings,
                style: AppThemes().title.merge(AppThemes().bold),
              ),
            ),
            Expanded(
              flex: 7,
              child: ListView(
                children: [
                  Divider(
                    color: const AppColors().black,
                    height: 1.0,
                  ),
                  SettingsTile(
                    title: AppLocalizations.of(context)!.common_app,
                    icon: Icons.app_settings_alt,
                    child: Consumer<Prefs>(
                      builder: (context, prefs, child) => Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            child: Text(
                              AppLocalizations.of(context)!.reset_title,
                              style: AppThemes()
                                  .body
                                  .merge(AppThemes().spacedLetters)
                                  .merge(AppThemes().underlined),
                            ),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _clearSharedPreferences(context, prefs);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    color: const AppColors().black,
                    height: 1.0,
                  ),
                  SettingsTile(
                    title: AppLocalizations.of(context)!.settings_language,
                    icon: Icons.language,
                    child: Consumer<Prefs>(
                      builder: (context, prefs, child) => Column(
                        children: [
                          LanguageRadio(
                            label: 'Deutsch',
                            value: 'de',
                            prefs: prefs,
                          ),
                          LanguageRadio(
                            label: 'English',
                            value: 'en',
                            prefs: prefs,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: const AppColors().black,
                    height: 1.0,
                  ),
                  SettingsTile(
                    title: AppLocalizations.of(context)!.settings_vr_goggles,
                    icon: Icons.vrpano,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          child: Text(
                            AppLocalizations.of(context)!
                                .settings_screen_calibration,
                            style: AppThemes()
                                .body
                                .merge(AppThemes().spacedLetters)
                                .merge(AppThemes().underlined),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            AutoRouter.of(context).push(
                              UnityRouter(children: [UnitySettingsRoute()]),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    color: const AppColors().black,
                    height: 1.0,
                  ),
                  SettingsTile(
                    title: AppLocalizations.of(context)!.settings_licenses,
                    icon: Icons.description,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            AutoRouter.of(context).push(const LicensesRoute());
                          },
                          child: Text(
                            AppLocalizations.of(context)!
                                .settings_licenses_packages,
                            style: AppThemes()
                                .body
                                .merge(AppThemes().spacedLetters)
                                .merge(AppThemes().underlined),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageRadio extends StatelessWidget {
  const LanguageRadio({
    super.key,
    required this.label,
    required this.value,
    required this.prefs,
  });

  final String label;
  final String value;
  final Prefs prefs;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: AppThemes().body,
      ),
      leading: Radio<String>(
        value: value,
        groupValue: prefs.locale,
        onChanged: (String? locale) {
          HapticFeedback.mediumImpact();
          prefs.locale = locale!;
        },
        fillColor: MaterialStateProperty.all(const AppColors().black),
      ),
    );
  }
}
