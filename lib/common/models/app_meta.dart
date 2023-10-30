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

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:visualr_app/common/services/parse_service.dart';

Future<String> getDeviceName() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model;
  }
  if (Platform.isIOS) {
    final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine;
  }
  return 'n/a';
}

class AppMeta {
  String appVersion;
  String buildNumber;
  String locale;
  String device;

  AppMeta({
    required this.appVersion,
    required this.buildNumber,
    required this.locale,
    required this.device,
  });

  factory AppMeta.fromJson(Map<String, dynamic> data) {
    return AppMeta(
      appVersion: ParseService.cast<String>(
        data['appVersion'],
        'appVersion',
      ),
      buildNumber: ParseService.cast<String>(
        data['buildNumber'],
        'buildNumber',
      ),
      locale: ParseService.cast<String>(
        data['locale'],
        'locale',
      ),
      device: ParseService.tryCast<String>(
            data['device'],
          ) ??
          'n/a',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'device': device,
      'locale': locale,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
