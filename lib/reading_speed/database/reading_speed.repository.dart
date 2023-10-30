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

import 'package:package_info_plus/package_info_plus.dart';
import 'package:visualr_app/common/database/repository.dart';
import 'package:visualr_app/common/models/app_meta.dart';
import 'package:visualr_app/common/models/user.dart';
import 'package:visualr_app/objectbox.g.dart';
import 'package:visualr_app/reading_speed/models/app_meta.dart';
import 'package:visualr_app/reading_speed/models/sequence.model.dart';
import 'package:visualr_app/reading_speed/models/step.dart';
import 'package:visualr_app/reading_speed/models/summary.dart';

class ReadingSpeedTestSequenceRepository
    extends Repository<ReadingSpeedTestSequenceEntity> {
  ReadingSpeedTestSequenceRepository({required super.box});

  Future<void> save({
    required String locale,
    required User user,
    required ReadingSpeedSummary summary,
    required List<ReadingSpeedTestStep> steps,
  }) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String deviceName = await getDeviceName();
    final ReadingSpeedTestSequenceEntity dte = ReadingSpeedTestSequenceEntity(
      createdAt: DateTime.now(),
      user: user.toString(),
      summary: summary.toString(),
      appMeta: ReadingSpeedAppMeta(
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        locale: locale,
        device: deviceName,
      ).toString(),
      steps: steps.map((step) => step.toString()).toList(),
    );
    box.put(dte);
  }

  bool delete({int? id}) {
    if (id == null) {
      final queryBuilder = box.query()
        ..order(
          ReadingSpeedTestSequenceEntity_.createdAt,
          flags: Order.descending,
        );
      final query = queryBuilder.build();
      final ReadingSpeedTestSequenceEntity? sequence = query.findFirst();
      if (sequence == null) {
        return false;
      }
      return box.remove(sequence.id);
    }
    return box.remove(id);
  }

  @override
  List<ReadingSpeedTestSequenceEntity> getAll() {
    final list = box.getAll();
    return list;
  }
}
