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

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualr_app/ipda/services/service.dart';

import '../../setup.dart';
import '../data.dart';

Future<void> sendUserAnswer({
  required IPDAService service,
  required int answer,
}) async {
  service.incomingStream.add(answer);
  return Future.delayed(Duration.zero);
}

void main() {
  group("IPDAService", () {
    late IPDAService service;
    late SharedPreferences prefs;
    setUpAll(() async => setupTests());
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = await IPDAService.startService();
      service.displaySize = displaySize;
    });
    test('should be created without errors', () async {
      expect(
        () => service,
        returnsNormally,
      );
    });
    test('should stop all streams on stop()', () {
      expect(service.isRunning, true);
      service.stop();
      expect(service.isRunning, false);
    });
    test('should go through full test sequence', () async {
      await sendUserAnswer(service: service, answer: 2);
      expect(service.manager.answers.raw, ipda.answers.raw.sublist(0, 1));
      expect(
        service.manager.answers.decoded,
        ipda.answers.decoded.sublist(0, 1),
      );
      await sendUserAnswer(service: service, answer: 3);
      expect(
        service.manager.answers.raw,
        ipda.answers.raw.sublist(0, 2),
      );
      expect(
        service.manager.answers.decoded,
        ipda.answers.decoded.sublist(0, 2),
      );
      await sendUserAnswer(service: service, answer: 2);
      expect(
        service.manager.answers.raw,
        ipda.answers.raw.sublist(0, 3),
      );
      expect(
        service.manager.answers.decoded,
        ipda.answers.decoded.sublist(0, 3),
      );
      await sendUserAnswer(service: service, answer: 3);
      expect(
        service.manager.answers.raw,
        ipda.answers.raw.sublist(0, 4),
      );
      expect(
        service.manager.answers.decoded,
        ipda.answers.decoded.sublist(0, 4),
      );
      expect(prefs.getDouble("ipd"), ipd);
    });
  });
}
