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

import 'package:permission_handler/permission_handler.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/theme/themes.dart';
import 'package:visualr_app/views/onboarding/onboarding_layout.dart';
import 'package:visualr_app/widgets/toast_helper.dart';

List<Permission> permissionsNeeded = [
  Permission.microphone,
];

class PermissionsSlide extends StatelessWidget {
  final VoidCallback action;
  const PermissionsSlide({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: AppLocalizations.of(context)!.onboarding_permissions,
      body: Container(
        alignment: Alignment.topLeft,
        child: Text(
          AppLocalizations.of(context)!.onboarding_permissions_copy,
          style: AppThemes().body.merge(AppThemes().spacedLetters),
        ),
      ),
      button: ElevatedButton(
        onPressed: () {
          bool allGranted = true;
          permissionsNeeded.request().then((statuses) {
            Future.forEach<MapEntry<Permission, PermissionStatus>>(
              statuses.entries.toList(),
              (status) async =>
                  {if (!await status.key.isGranted) allGranted = false},
            ).then((_) {
              if (allGranted) {
                action.call();
              } else {
                createBasicToast(
                  message: AppLocalizations.of(context)!
                      .onboarding_permissions_toast,
                ).show(context);
              }
            });
          });
        },
        child: Text(
          AppLocalizations.of(context)!.common_accept,
          style: AppThemes().body.merge(AppThemes().spacedLetters),
        ),
      ),
    );
  }
}
