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
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualr_app/common/models/display_size.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/ipda/models/ipda.dart';
import 'package:visualr_app/ipda/models/step.dart';
import 'package:visualr_app/ipda/services/manager.dart';
import 'package:visualr_app/main.dart';

class IPDAService {
  final StreamController<int> incomingStream = StreamController();
  late final StreamSubscription incomingStreamSubscription;
  final StreamController<IPDAStep> outgoingStream = StreamController();
  late final IPDAManager manager;
  late DisplaySize displaySize;

  static Future<IPDAService> startService() async {
    final manager = await IPDAManager.startManager();
    return IPDAService(
      manager: manager,
    );
  }

  IPDAService({
    required this.manager,
  }) {
    incomingStreamSubscription =
        incomingStream.stream.listen(onReceiveResultEvent);
    outgoingStream.add(manager.current);
  }

  Future<void> onReceiveResultEvent(int answer) async {
    manager.updateTestResults(answer: answer);
    final IPDAStep? currentStep = await manager.createTestEvent();
    if (currentStep == null) {
      await storeTestResults();
      await stop();
      return;
    } else {
      outgoingStream.add(currentStep);
    }
  }

  Future<int> storeTestResults() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final prefs = Prefs(sharedPrefs);
    prefs.ipd = manager.answers.decoded
        .map((answer) => manager.calculatePupillaryDistancePerStep(answer))
        .average;
    return objectBox.ipda.save(
      ipda: IPDA(
        user: prefs.user,
        createdAt: DateTime.now(),
        ipd: prefs.ipd,
        answers: manager.answers,
        displaySize: displaySize,
      ),
      locale: prefs.locale,
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
