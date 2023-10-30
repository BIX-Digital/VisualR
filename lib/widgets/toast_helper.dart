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

import 'package:another_flushbar/flushbar.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/theme/themes.dart';

List<BoxShadow> boxShadows = [
  BoxShadow(
    offset: const Offset(0.0, 1.0),
    blurRadius: 18.0,
    color: const AppColors().black.withOpacity(0.12),
  ),
  BoxShadow(
    offset: const Offset(0.0, 6.0),
    blurRadius: 10.0,
    color: const AppColors().black.withOpacity(0.14),
  ),
  BoxShadow(
    offset: const Offset(0.0, 3.0),
    blurRadius: 5.0,
    spreadRadius: 1.0,
    color: const AppColors().black.withOpacity(0.20),
  ),
];

Flushbar createBasicToast({
  required String message,
  IconData? icon,
  Duration duration = const Duration(seconds: 2),
}) {
  return Flushbar(
    boxShadows: boxShadows,
    flushbarPosition: FlushbarPosition.TOP,
    messageText: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: AppThemes()
              .small
              .merge(AppThemes().bold)
              .merge(AppThemes().white),
        ),
        if (icon == null)
          Container()
        else
          Icon(
            icon,
            color: const AppColors().white,
          ),
      ],
    ),
    duration: duration,
    isDismissible: false,
    borderRadius: BorderRadius.circular(30.0),
    padding: const EdgeInsets.all(14.0),
    backgroundColor: const AppColors().black,
    maxWidth: 250.0,
  );
}
