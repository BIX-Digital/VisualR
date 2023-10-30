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
import 'package:visualr_app/common/models/display_size.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/ipda/models/step.dart';
import 'package:visualr_app/ipda/services/service.dart';
import 'package:visualr_app/meta.dart';
import 'package:visualr_app/views/unity/unity_view.dart';
import 'package:visualr_app/widgets/unity_transition.dart';

const int arcMinSize = 700;

@RoutePage()
class UnityIPDAPage extends UnityViewPage {
  const UnityIPDAPage({
    super.key,
    super.showInstructions = true,
    super.unityView = UnityView.ipda,
  });

  @override
  State<UnityViewPage> createState() => _UnityIPDAPageState();
}

class _UnityIPDAPageState extends UnityViewPageState {
  IPDAService? svc;
  final StreamController<IPDAStep> _updateStateStream =
      StreamController<IPDAStep>();
  IPDAStep? _ipdaStep;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      svc = await IPDAService.startService();
    });
  }

  @override
  void onUnityCreated(
    UnityWidgetController controller,
    Prefs prefs,
    BuildContext context,
  ) {
    screenBrightnessService.setBrightness();
    setUnityCloseMessage();
    unityWidgetController = controller;
    localizedTextService
        .getLocalizedText(widget.unityView.toShortString(), prefs)
        .then((localizedText) {
      unityWidgetController!.postMessage(
        'unityModuleIdle',
        'OpenIpd',
        '''
          {
            "arcMinFont": $arcMinFont,
            "arcMinSize": $arcMinSize,
            "debug": ${prefs.debug},
            "height": ${View.of(context).physicalSize.height},
            "instructions": "${widget.showInstructions}",
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
      case 'IpdReady':
        svc!.displaySize = DisplaySize(
          dpi: (message.data as Map<String, dynamic>)["dpi"] as double,
          height: View.of(context).physicalSize.height,
          width: View.of(context).physicalSize.width,
        );
        _updateStateStream.stream.listen((IPDAStep ipdaStep) {
          if (ipdaStep != _ipdaStep) {
            Future.delayed(
              const Duration(seconds: 1),
              () => sendIpdaStep(ipdaStep),
            );
          }
        });
      case 'IpdAnswer':
        registerUserAnswer((message.data as Map<String, dynamic>)['answer']);
    }
  }

  @override
  void registerUserAnswer(dynamic response) {
    svc?.incomingStream.add(response as int);
  }

  void sendIpdaStep(IPDAStep ipdaStep) {
    unityWidgetController!.postMessage(
      'unityModuleIpd',
      'IpdStep',
      '''
          {
            "ipdValues": ${ipdaStep.ipdaValues},
            "step": ${ipdaStep.step}
          }
        ''',
    );
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
                unityClose!.status = UnityTestState.success;
                Future.delayed(
                  const Duration(seconds: 1),
                  () => unityWidgetController!.postMessage(
                    'unityModuleIpd',
                    'IpdEnd',
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
