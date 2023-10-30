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
import 'package:visualr_app/common/models/user.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/theme/themes.dart';
import 'package:visualr_app/views/onboarding/onboarding_layout.dart';

class IdentificationSlide extends StatefulWidget {
  final VoidCallback action;
  final Prefs prefs;
  final ScrollController scrollController;
  const IdentificationSlide({
    super.key,
    required this.action,
    required this.prefs,
    required this.scrollController,
  });

  @override
  State<IdentificationSlide> createState() => _IdentificationSlideState();
}

class _IdentificationSlideState extends State<IdentificationSlide> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _userController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
  }

  void _onFocusChange() {
    _focusNode.hasFocus
        ? widget.scrollController.animateTo(
            200.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          )
        : widget.scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: AppLocalizations.of(context)!.onboarding_identification,
      body: Container(
        alignment: Alignment.topLeft,
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.onboarding_identification_copy,
              style: AppThemes().body.merge(AppThemes().spacedLetters),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Form(
                  key: _formKey,
                  onChanged: () => setState(
                    () => isButtonEnabled = _formKey.currentState!.validate(),
                  ),
                  child: TextFormField(
                    maxLength: 20,
                    focusNode: _focusNode,
                    controller: _userController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const AppColors().white,
                      errorStyle: AppThemes().error,
                      errorBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0)),
                        borderSide: BorderSide(color: const AppColors().error),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                      hintText: AppLocalizations.of(context)!.common_study_id,
                    ),
                    validator: (name) {
                      if (name == null || name.isEmpty) {
                        return AppLocalizations.of(context)!
                            .onboarding_identification_error;
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      button: ElevatedButton(
        onPressed: isButtonEnabled
            ? () {
                widget.prefs.user = User.generateId(_userController.text);
                FocusManager.instance.primaryFocus?.unfocus();
                widget.action.call();
              }
            : null,
        child: Text(
          AppLocalizations.of(context)!.common_confirm,
          style: AppThemes().body.merge(AppThemes().spacedLetters),
        ),
      ),
    );
  }
}
