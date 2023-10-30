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
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/common/services/screen_brightness_service.dart';
import 'package:visualr_app/contrast/models/color.dart';
import 'package:visualr_app/contrast/models/step.dart';
import 'package:visualr_app/contrast/services/manager.dart';
import 'package:visualr_app/main.dart';

class ContrastService {
  final Color darkBackgroundColor = const Color(r: 26, g: 26, b: 26);
  final Color lightBackgroundColor = const Color(r: 180, g: 180, b: 180);
  final double probabilityOfFakeStep = 0.15;
  final StreamController<int> incomingStream = StreamController();
  late final StreamSubscription incomingStreamSubscription;
  final StreamController<ContrastStep?> outgoingStream = StreamController();
  late final ContrastManager manager;
  final bool isPresentation;
  final bool darkBackground;
  late final Color backgroundColor;
  late final Color color;

  static Future<ContrastService> startService({
    bool isPresentation = false,
    bool darkBackground = true,
  }) async {
    final manager = await ContrastManager.startManager(
      isPresentation: isPresentation,
      darkBackground: darkBackground,
    );
    return ContrastService(
      manager: manager,
      isPresentation: isPresentation,
      darkBackground: darkBackground,
    );
  }

  ContrastService({
    required this.manager,
    this.isPresentation = false,
    this.darkBackground = true,
  }) {
    incomingStreamSubscription =
        incomingStream.stream.listen(onReceiveResultEvent);
    outgoingStream.add(manager.current);
    backgroundColor =
        darkBackground ? darkBackgroundColor : lightBackgroundColor;
    color = darkBackground
        ? const Color(r: 255, g: 255, b: 255)
        : const Color(r: 0, g: 0, b: 0);
  }

  Future<void> onReceiveResultEvent(int answer) async {
    if (isPresentation) {
      final ContrastStep? step = await manager.createTestEvent();
      step == null ? await stop() : outgoingStream.add(step);
      return;
    }
    manager.updateTestResults(answer: answer);
    final ContrastStep? currentTest = isNextStepFake
        ? manager.createTestWithDifferentRingNum()
        : await manager.createTestEvent();
    if (currentTest == null) {
      await storeTestResults();
      await stop();
      return;
    } else {
      outgoingStream.add(currentTest);
    }
  }

  Future<int> storeTestResults() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final prefs = Prefs(sharedPrefs);
    return objectBox.contrast.save(
      steps: manager.steps,
      locale: prefs.locale,
      user: prefs.user,
      brightness: await ScreenBrightnessService().brightness,
      summary: manager.summary!,
      backgroundColor: backgroundColor,
      isDark: darkBackground,
    );
  }

  bool get isNextStepFake => math.Random().nextDouble() < probabilityOfFakeStep;

  bool get isRunning =>
      !incomingStream.isClosed &&
      incomingStream.hasListener &&
      !outgoingStream.isClosed;

  Future<void> stop() async {
    await incomingStreamSubscription.cancel();
    await incomingStream.close();
    if (outgoingStream.hasListener) {
      await outgoingStream.close();
    }
  }
}
