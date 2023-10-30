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
import 'package:visualr_app/ipda/models/ipda.dart';
import 'package:visualr_app/ipda/models/ipda.model.dart';

import '../../data.dart';
import '../data.dart';

void main() {
  final Map<String, dynamic> json = {
    'createdAt': createdAt.millisecondsSinceEpoch,
    'user': user.toJson(),
    'displaySize': displaySize.toJson(),
    'answers': answers.toJson(),
    'ipd': ipd,
    'appMeta': appMeta.toJson(),
  };
  group('IPDAAnswers', () {
    test('should be created without errors', () {
      expect(
        () => ipda,
        returnsNormally,
      );
    });
    test('should be convertible to JSON', () {
      expect(ipda.toJson(), json);
    });
    test('should be created from entity', () {
      final IPDAEntity entity = IPDAEntity(
        answers: answers.toString(),
        appMeta: appMeta.toString(),
        createdAt: createdAt,
        displaySize: displaySize.toString(),
        ipd: ipd,
        user: user.toString(),
      );
      final IPDA ipdaFromEntity = entity.toDTO();
      expect(ipdaFromEntity.answers.raw, answers.raw);
      expect(ipdaFromEntity.answers.decoded, answers.decoded);
      expect(ipdaFromEntity.appMeta!.appVersion, appMeta.appVersion);
      expect(ipdaFromEntity.createdAt, createdAt);
      expect(ipdaFromEntity.displaySize.width, displaySize.width);
      expect(ipdaFromEntity.ipd, ipd);
      expect(ipdaFromEntity.user.displayName, user.displayName);
    });
  });
}
