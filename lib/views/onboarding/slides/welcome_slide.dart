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

import 'package:visualr_app/common.dart';
import 'package:visualr_app/theme/themes.dart';
import 'package:visualr_app/views/onboarding/onboarding_layout.dart';

class WelcomeSlide extends StatelessWidget {
  final VoidCallback action;
  const WelcomeSlide({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: AppLocalizations.of(context)!.onboarding_welcome,
      body: Container(
        alignment: Alignment.topLeft,
        child: Text(
          AppLocalizations.of(context)!.onboarding_welcome_copy,
          style: AppThemes().body.merge(AppThemes().spacedLetters),
        ),
      ),
      button: ElevatedButton(
        onPressed: action,
        child: Text(
          AppLocalizations.of(context)!.common_continue,
          style: AppThemes().body.merge(AppThemes().spacedLetters),
        ),
      ),
    );
  }
}
