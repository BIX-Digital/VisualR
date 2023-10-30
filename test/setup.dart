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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualr_app/common/database/objectbox.dart';
import 'package:visualr_app/main.dart';

Future<void> setupTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
          const MethodChannel('github.com/aaassseee/screen_brightness'),
          (MethodCall methodCall) async {
    if (methodCall.method == 'getScreenBrightness') {
      return 0.5;
    }
    return null;
  });
  objectBox = await ObjectBox.create(directory: ".");
  PackageInfo.setMockInitialValues(
    appName: "VisualR",
    buildNumber: "1",
    buildSignature: "buildSignature",
    packageName: "visualr_package_name",
    version: "1.0.0",
  );
  SharedPreferences.setMockInitialValues({});
}
