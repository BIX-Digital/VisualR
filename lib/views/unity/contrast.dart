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

import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/contrast/models/step.dart';
import 'package:visualr_app/contrast/services/service.dart';
import 'package:visualr_app/meta.dart';
import 'package:visualr_app/views/unity/unity_view.dart';
import 'package:visualr_app/widgets/unity_transition.dart';

@RoutePage()
class UnityContrastPage extends UnityViewPage {
  const UnityContrastPage({
    super.key,
    super.showInstructions = true,
    required super.unityView,
  });

  @override
  State<UnityViewPage> createState() => _UnityContrastPageState();
}

class _UnityContrastPageState extends UnityViewPageState {
  final StreamController<ContrastStep> _updateStateStream =
      StreamController<ContrastStep>();
  ContrastService? svc;
  ContrastStep? _contrastTest;

  @override
  void onUnityCreated(
    UnityWidgetController controller,
    Prefs prefs,
    BuildContext context,
  ) {
    screenBrightnessService.setBrightness();
    unityWidgetController = controller;
    setUnityCloseMessage();
    localizedTextService
        .getLocalizedText('contrast', prefs)
        .then((localizedText) {
      unityWidgetController!.postMessage(
        'unityModuleIdle',
        'OpenContrast',
        '''
          {
            "arcMinFont": $arcMinFont,
            "backgroundColor": ${svc!.backgroundColor},
            "color": ${svc!.color},
            "debug": ${prefs.debug},
            "height": ${View.of(context).physicalSize.height},
            "instructions": "${widget.showInstructions}",
            "ipd": ${prefs.ipd},
            "locale": "${prefs.locale}",
            "screenToLensDistance": ${prefs.screenToLensDistance},
            "text": $localizedText,
            "width": ${View.of(context).physicalSize.width}
          }
        ''',
      );
    });
  }

  @override
  void registerUserAnswer(dynamic response) {
    svc?.incomingStream.add(response as int);
  }

  @override
  void onUnityMessage(
    UnityMessage message,
    BuildContext context, [
    Prefs? prefs,
  ]) {
    switch (message.name) {
      case 'Close':
        HapticFeedback.mediumImpact();
        screenBrightnessService.resetBrightness();
        closeUnity(context);
      case 'ContrastAnswer':
        registerUserAnswer((message.data as Map<String, dynamic>)['answer']);
      case 'ContrastReady':
        _updateStateStream.stream.listen((ContrastStep contrastTest) {
          if (contrastTest != _contrastTest) {
            Future.delayed(
              const Duration(seconds: 1),
              () => sendRings(contrastTest),
            );
          }
        });
    }
  }

  void sendRings(ContrastStep contrastTest) {
    contrastTest.createdAt = DateTime.now();
    setState(() {
      _contrastTest = contrastTest;
    });
    unityWidgetController?.postMessage(
      'unityModuleContrast',
      'ContrastTest',
      _contrastTest!.toString(unity: true),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final Prefs prefs = Prefs(sharedPreferences);
      svc = await ContrastService.startService(
        isPresentation: prefs.presentation,
        darkBackground: widget.unityView == UnityView.contrastDark,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Prefs>(
      builder: (context, prefs, child) => StreamBuilder(
        stream: svc?.outgoingStream.stream,
        builder: (context, snapshot) {
          // Wrapping this inside a condition as a state change of
          // showTransition from false to true will trigger this again and as
          // the connection will be in a state of done it would trigger saving
          // the test results again
          if (showTransition == false) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                // For now it is unclear what we should do while the
                // Stream is in a waiting state so we just break
                break;
              case ConnectionState.active:
                _updateStateStream.add(snapshot.data!);
              case ConnectionState.done:
                unityClose!.status = prefs.presentation
                    ? UnityTestState.error
                    : UnityTestState.success;
                if (!prefs.presentation) {
                  final Set<String> finishedTests = prefs.finishedTests;
                  finishedTests.add(widget.unityView.toShortString());
                  prefs.finishedTests = finishedTests;
                }
                Future.delayed(
                  const Duration(seconds: 1),
                  () => unityWidgetController!.postMessage(
                    'unityModuleContrast',
                    'ContrastEnd',
                    '',
                  ),
                );
            }
          }
          return Consumer<Prefs>(
            builder: (context, prefs, child) => UnityWidget(
              onUnityCreated: (UnityWidgetController controller) =>
                  onUnityCreated(controller, prefs, context),
              onUnityMessage: (dynamic message) {
                message = cleanUnityMessage(message.toString());
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
        },
      ),
    );
  }
}
