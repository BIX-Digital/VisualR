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

import 'package:visualr_app/common/models/app_meta.dart';
import 'package:visualr_app/common/services/parse_service.dart';

class ContrastAppMeta extends AppMeta {
  double screenBrightness;
  ContrastAppMeta({
    required super.appVersion,
    required super.buildNumber,
    required super.locale,
    required super.device,
    required this.screenBrightness,
  });

  factory ContrastAppMeta.fromJson(Map<String, dynamic> data) {
    return ContrastAppMeta(
      appVersion: ParseService.cast<String>(
        data['appVersion'],
        'appVersion',
      ),
      buildNumber: ParseService.cast<String>(
        data['buildNumber'],
        'buildNumber',
      ),
      device: ParseService.tryCast<String>(
            data['device'],
          ) ??
          'n/a',
      locale: ParseService.cast<String>(
        data['locale'],
        'locale',
      ),
      screenBrightness: ParseService.cast<double>(
        data['screenBrightness'],
        'screenBrightness',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'device': device,
      'locale': locale,
      'screenBrightness': screenBrightness,
    };
  }
}
