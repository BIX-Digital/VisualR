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
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/common/services/localized_text_service.dart';
import 'package:visualr_app/common/services/screen_brightness_service.dart';
import 'package:visualr_app/meta.dart';

class UnityMessage {
  final String name;
  final dynamic data;

  UnityMessage({required this.name, required this.data});

  UnityMessage.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        data = json['data'];
}

enum UnityTestState {
  error,
  success,
  incomplete,
}

class UnityCloseMessage {
  UnityTestState status;
  final UnityView view;

  UnityCloseMessage({required this.status, required this.view});
}

const int arcMinFont = 55;

abstract class UnityViewPage extends StatefulWidget {
  final bool showInstructions;
  final UnityView unityView;

  const UnityViewPage({
    super.key,
    required this.showInstructions,
    required this.unityView,
  });
}

abstract class UnityViewPageState extends State<UnityViewPage> {
  bool showTransition = true;
  UnityCloseMessage? unityClose;
  final LocalizedTextService localizedTextService = LocalizedTextService();
  late final ScreenBrightnessService screenBrightnessService;
  UnityWidgetController? unityWidgetController;

  String cleanUnityMessage(String message) {
    return message.replaceAll('@UnityMessage@', '');
  }

  @override
  void initState() {
    screenBrightnessService =
        ScreenBrightnessService.fromView(widget.unityView);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    Future.delayed(
      const Duration(seconds: 3),
      () => setState(() => showTransition = false),
    );
    super.initState();
  }

  @override
  void dispose() {
    unityWidgetController!.dispose();
    super.dispose();
  }

  void setUnityCloseMessage() {
    unityClose = UnityCloseMessage(
      status: UnityTestState.incomplete,
      view: widget.unityView,
    );
  }

  void closeUnity(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    setState(() {
      showTransition = true;
    });
    // final bool tmpCompleted = unityClose!.completed;
    Future.delayed(
      const Duration(seconds: 3),
      () => AutoRouter.of(context).pop(unityClose),
    );
  }

  void onUnityCreated(
    UnityWidgetController controller,
    Prefs prefs,
    BuildContext context,
  ) {
    throw UnimplementedError('onUnityCreated() has not been implemented.');
  }

  void onUnityMessage(
    UnityMessage message,
    BuildContext context, [
    Prefs? prefs,
  ]) {
    throw UnimplementedError('onUnityMessage() has not been implemented.');
  }

  void registerUserAnswer(dynamic result) {
    throw UnimplementedError('registerUserAnswer() has not been implemented.');
  }
}
