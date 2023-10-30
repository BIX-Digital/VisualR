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
import 'package:visualr_app/ipda/models/ipda.dart';
import 'package:visualr_app/ipda/models/ipda.model.dart';

class IPDARepository extends Repository<IPDAEntity> {
  IPDARepository({required super.box});
  Future<int> save({
    required IPDA ipda,
    required String locale,
  }) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String deviceName = await getDeviceName();
    final IPDAEntity ipdaEntity = IPDAEntity(
      createdAt: DateTime.now(),
      user: ipda.user.toString(),
      displaySize: ipda.displaySize.toString(),
      ipd: ipda.ipd,
      answers: ipda.answers.toString(),
      appMeta: AppMeta(
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        locale: locale,
        device: deviceName,
      ).toString(),
    );
    return box.put(ipdaEntity);
  }

  @override
  List<IPDAEntity> getAll() {
    return box.getAll();
  }
}
