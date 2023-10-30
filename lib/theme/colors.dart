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

import 'package:flutter/material.dart';

@immutable
class AppColors {
  Color get background => const Color(0xFFFBFBFB);
  Color get black => const Color(0xFF000000);
  Color get cornflower => const Color(0xFFBDCCF3);
  Color get error => const Color(0xFFFF4785);
  Color get grey => const Color(0xFF979797);
  Color get indicator => const Color(0xFFD9D9D9);
  Color get orchid => const Color(0xFF878BE8);
  Color get transparent => const Color(0x00000000);
  Color get turquoise => const Color(0xFFBDF3F0);
  Color get white => const Color(0xFFFFFFFF);

  const AppColors();
}
