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
import 'package:visualr_app/contrast/models/app_meta.dart';
import 'package:visualr_app/contrast/models/color.dart';
import 'package:visualr_app/contrast/models/step.dart';
import 'package:visualr_app/contrast/models/summary.dart';
import 'package:visualr_app/contrast/models/test.model.dart';
import 'package:visualr_app/objectbox.g.dart';

class ContrastTestRepository extends Repository<ContrastTestEntity> {
  ContrastTestRepository({required super.box});

  Future<int> save({
    required List<ContrastStep> steps,
    required String locale,
    required User user,
    required double brightness,
    required ContrastSummary summary,
    required Color backgroundColor,
    required bool isDark,
  }) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String deviceName = await getDeviceName();
    final ContrastTestEntity contrastTestEntity = ContrastTestEntity(
      createdAt: DateTime.now(),
      isDark: isDark,
      user: user.toString(),
      backgroundColor: backgroundColor.toString(),
      summary: summary.toString(),
      steps: steps.map((step) => step.toString()).toList(),
      appMeta: ContrastAppMeta(
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        locale: locale,
        device: deviceName,
        screenBrightness: brightness,
      ).toString(),
    );
    return box.put(contrastTestEntity);
  }

  /// Deletes the test sequence with the provided [id]. If [id] is not specified it will delete the latest one.
  bool delete({int? id}) {
    if (id == null) {
      final queryBuilder = box.query()
        ..order(
          ContrastTestEntity_.createdAt,
          flags: Order.descending,
        );
      final query = queryBuilder.build();
      final ContrastTestEntity? sequence = query.findFirst();
      if (sequence == null) {
        return false;
      }
      return box.remove(sequence.id);
    }
    return box.remove(id);
  }

  @override
  List<ContrastTestEntity> getAll() {
    return box.getAll();
  }

  List<ContrastTestEntity> getAllLightOrDark({required bool isDark}) {
    return box.query(ContrastTestEntity_.isDark.equals(isDark)).build().find();
  }
}
