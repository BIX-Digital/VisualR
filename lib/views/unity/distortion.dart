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

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/contrast/models/color.dart';
import 'package:visualr_app/distortion/models/line.dart';
import 'package:visualr_app/distortion/services/service.dart';
import 'package:visualr_app/meta.dart';
import 'package:visualr_app/views/unity/unity_view.dart';
import 'package:visualr_app/widgets/unity_transition.dart';

const double dotSize = 6.0;
const int numberOfLinesBeforePause = 40;
const Color distortionColor = Color(r: 150, g: 150, b: 150);

@RoutePage()
class UnityDistortionPage extends UnityViewPage {
  const UnityDistortionPage({
    super.key,
    super.showInstructions = true,
    super.unityView = UnityView.distortion,
  });

  @override
  State<UnityViewPage> createState() => _UnityDistortionPageState();
}

class _UnityDistortionPageState extends UnityViewPageState {
  final StreamController _updateStateStream = StreamController<Line>();
  DistortionService? svc;
  Line? _line;
  bool partTwo = false;
  int numberOfLines = 0;

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
      final Map<String, dynamic> jsonObject =
          json.decode(localizedText) as Map<String, dynamic>;
      final instructionString = json.encode(
        (jsonObject['instructionsList'] as List<dynamic>)[0],
      );
      unityWidgetController!.postMessage(
        'unityModuleIdle',
        'OpenDistortion',
        '''
          {
            "arcMinFont": $arcMinFont,
            "color": $distortionColor,
            "debug": ${prefs.debug},
            "dotSize": $dotSize,
            "height": ${View.of(context).physicalSize.height},
            "instructions": "${widget.showInstructions}",
            "ipd": ${prefs.ipd},
            "locale": "${prefs.locale}",
            "part": 1,
            "screenToLensDistance": ${prefs.screenToLensDistance},
            "text": $instructionString,
            "width": ${View.of(context).physicalSize.width}
          }
        ''',
      );
    });
  }

  void sendLine(Line line) {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _line = line;
        _line!.createdAt = DateTime.now();
      });
      if (partTwo &&
          (numberOfLines != 0) &&
          (numberOfLines % numberOfLinesBeforePause == 0)) {
        unityWidgetController?.postMessage(
          'unityModuleDistortion',
          'DistortionPause',
          '',
        );
      } else {
        unityWidgetController?.postMessage(
          'unityModuleDistortion',
          'DistortionTest',
          _line!.toString(unity: true),
        );
      }
      if (partTwo) {
        setState(() {
          numberOfLines++;
        });
      }
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
      case 'DistortionAnswer':
        registerUserAnswer((message.data as Map<String, dynamic>)['answer']);
      case 'DistortionReady':
        if (!_updateStateStream.hasListener) {
          _updateStateStream.stream.listen((line) {
            if ((line as Line) != _line) {
              sendLine(line);
            }
          });
        } else {
          sendLine(_line!);
        }
    }
  }

  @override
  void registerUserAnswer(dynamic answer) {
    final boolAnswer = switch (answer) {
      "Yes" => true,
      "No" => false,
      "NoAnswer" => null,
      _ => true
    };
    svc?.incomingStream.add(boolAnswer);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final Prefs prefs = Prefs(sharedPreferences);
      svc = await DistortionService.startService(
        isPresentation: prefs.presentation,
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
                final line = snapshot.data!;
                if (line.dotSpacingId == 0 || partTwo) {
                  _updateStateStream.add(line);
                } else {
                  localizedTextService
                      .getLocalizedText(widget.unityView.toShortString(), prefs)
                      .then((localizedText) {
                    setState(() {
                      partTwo = true;
                    });
                    if (line != _line) {
                      setState(() {
                        _line = line;
                      });
                    }
                    final Map<String, dynamic> jsonObject =
                        json.decode(localizedText) as Map<String, dynamic>;
                    final instructionString = json.encode(
                      (jsonObject['instructionsList'] as List<dynamic>)[1],
                    );
                    Future.delayed(
                      const Duration(seconds: 1),
                      () => unityWidgetController!.postMessage(
                        'unityModuleDistortion',
                        'OpenDistortionPart2',
                        '''
                        {
                          "arcMinFont": $arcMinFont,
                          "color": $distortionColor,
                          "debug": ${prefs.debug},
                          "dotSize": $dotSize,
                          "height": ${View.of(context).physicalSize.height},
                          "instructions": "true",
                          "ipd": ${prefs.ipd},
                          "part": 2,
                          "locale": "${prefs.locale}",
                          "screenToLensDistance": ${prefs.screenToLensDistance},
                          "text": $instructionString,
                          "width": ${View.of(context).physicalSize.width}
                        }
                      ''',
                      ),
                    );
                  });
                }
              case ConnectionState.done:
                unityClose!.status = prefs.presentation
                    ? UnityTestState.error
                    : UnityTestState.success;
                if (!prefs.presentation) {
                  final Set<String> finishedTests = prefs.finishedTests;
                  finishedTests.add(widget.unityView.toShortString());
                  prefs.finishedTests = finishedTests;
                }
                // When we reach the end of the stream we want to let Unity
                // know that the test is complete and we can end it
                Future.delayed(
                  const Duration(seconds: 1),
                  () => unityWidgetController!.postMessage(
                    'unityModuleDistortion',
                    'DistortionEnd',
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
                onUnityMessage(
                  UnityMessage.fromJson(
                    json.decode(cleanUnityMessage(message.toString()))
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
