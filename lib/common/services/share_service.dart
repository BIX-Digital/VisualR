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

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> onShare(String content, String name) async {
    final PermissionStatus status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
    final tempDirectory = await getTemporaryDirectory();
    final File tempFile = File('${tempDirectory.path}/$name');
    await tempFile.writeAsString(content);
    await Share.shareXFiles(
      [XFile(tempFile.path)],
    );
  }
}
