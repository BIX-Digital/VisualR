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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualr_app/common/models/app_meta.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/distortion/models/app_meta.dart';
import 'package:visualr_app/distortion/models/line.dart';
import 'package:visualr_app/distortion/models/step.dart';
import 'package:visualr_app/distortion/models/test.dart';
import 'package:visualr_app/distortion/services/manager.dart';
import 'package:visualr_app/main.dart';

class DistortionService {
  final StreamController<bool?> incomingStream = StreamController();
  late final StreamSubscription incomingStreamSubscription;
  final StreamController<Line> outgoingStream = StreamController();
  late final DistortionManager manager;
  bool isPresentation;

  static Future<DistortionService> startService({
    bool isPresentation = false,
  }) async {
    final manager = await DistortionManager.startManager(
      isPresentation: isPresentation,
    );
    return DistortionService(manager: manager, isPresentation: isPresentation);
  }

  DistortionService({
    required this.manager,
    this.isPresentation = false,
  }) {
    incomingStreamSubscription = incomingStream.stream.listen(
      (bool? answer) => onReceiveResultEvent(answer: answer),
    );
    outgoingStream.add(manager.current);
  }

  Future<void> onReceiveResultEvent({bool? answer}) async {
    manager.current.answerGivenAt = DateTime.now();
    manager.updateTestResults(answer: answer);
    final Line? line = await manager.createTestEvent();
    if (line == null) {
      await storeTestResults();
      await stop();
    } else {
      outgoingStream.add(line);
    }
  }

  Future<int> storeTestResults() async {
    if (isPresentation) return 0;
    final sharedPrefs = await SharedPreferences.getInstance();
    final prefs = Prefs(sharedPrefs);
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String deviceName = await getDeviceName();
    return objectBox.distortion.save(
      test: DistortionTest(
        createdAt: DateTime.now(),
        user: prefs.user,
        appMeta: DistortionAppMeta(
          appVersion: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          locale: prefs.locale,
          device: deviceName,
        ),
        summary: manager.summary,
        scores: manager.scores,
        part1: manager.firstPartLines
            .where((line) => line.distorted == false && line.answer == false)
            .map<String>((line) => line.name)
            .toList(),
        missedPart1: manager.missedFirstPartLines,
        part2: manager.secondPartLines
            .map(
              (line) => DistortionStep(
                line: line.name,
                createdAt: line.createdAt,
                answerGivenAt: line.answerGivenAt,
                dotSpacing: getDotSpacing(line.dotSpacingId).toInt(),
                answer: line.answer,
              ),
            )
            .toList(),
      ),
    );
  }

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
