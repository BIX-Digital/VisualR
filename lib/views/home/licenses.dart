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
import 'package:visualr_app/oss_licenses.dart';
import 'package:visualr_app/routes/router.gr.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/theme/themes.dart';

@RoutePage()
class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44.0),
              child: Text(
                AppLocalizations.of(context)!.settings_licenses_packages,
                style: AppThemes().title.merge(AppThemes().bold),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 44.0),
              child: ListView.separated(
                itemCount: ossLicenses.length,
                separatorBuilder: (_, index) => const Divider(),
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 44.0),
                    child: ListTile(
                      title: Text(ossLicenses[index].name),
                      subtitle: Text(ossLicenses[index].description),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        AutoRouter.of(context).push(
                          LicenseDetailRoute(package: ossLicenses[index]),
                        );
                      },
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
