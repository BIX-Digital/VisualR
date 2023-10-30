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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:provider/provider.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/common/services/parse_service.dart';
import 'package:visualr_app/meta.dart';
import 'package:visualr_app/views/unity/unity_view.dart';
import 'package:visualr_app/widgets/unity_transition.dart';

@RoutePage()
class UnitySettingsPage extends UnityViewPage {
  const UnitySettingsPage({
    super.key,
    super.showInstructions = true,
    super.unityView = UnityView.settings,
  });

  @override
  State<UnityViewPage> createState() => _UnitySettingsPageState();
}

class _UnitySettingsPageState extends UnityViewPageState {
  @override
  void onUnityCreated(
    UnityWidgetController controller,
    Prefs prefs,
    BuildContext context,
  ) {
    screenBrightnessService.setBrightness();
    unityWidgetController = controller;
    localizedTextService
        .getLocalizedText(widget.unityView.toShortString(), prefs)
        .then((localizedText) {
      final String text = ParseService.cast<String>(
        ParseService.cast<Map<String, dynamic>>(
          json.decode(localizedText),
          "localizedText",
        )["text"],
        "text",
      );
      unityWidgetController!.postMessage(
        'unityModuleIdle',
        'OpenSettings',
        '''
          {
            "arcMinFont": $arcMinFont,
            "debug": ${prefs.debug},
            "height": ${View.of(context).physicalSize.height},
            "ipd": ${prefs.ipd},
            "locale": "${prefs.locale}",
            "screenToLensDistance": ${prefs.screenToLensDistance},
            "text": "$text"
          }
        ''',
      );
    });
  }

  @override
  void onUnityMessage(
    UnityMessage message,
    BuildContext context, [
    Prefs? prefs,
  ]) {
    switch (message.name) {
      case 'Close':
        screenBrightnessService.resetBrightness();
        HapticFeedback.mediumImpact();
        closeUnity(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Prefs>(
      builder: (context, prefs, child) => UnityWidget(
        onUnityCreated: (UnityWidgetController controller) =>
            onUnityCreated(controller, prefs, context),
        onUnityMessage: (dynamic message) {
          onUnityMessage(
            UnityMessage.fromJson(
              jsonDecode(cleanUnityMessage(message.toString()))
                  as Map<String, dynamic>,
            ),
            context,
          );
        },
        enablePlaceholder: showTransition,
        placeholder: const UnityTransition(),
      ),
    );
  }
}
