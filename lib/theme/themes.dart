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

import 'package:visualr_app/common.dart';
import 'package:visualr_app/theme/colors.dart';

@immutable
class AppThemes {
  // MATERIAL THEMES
  final CardTheme card = CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    margin: EdgeInsets.zero,
  );
  final DialogTheme dialog = DialogTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  );
  final ElevatedButtonThemeData elevatedButton = ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
    ),
  );

  // FONT FAMILIES
  final TextStyle sora = const TextStyle(fontFamily: 'Sora');

  // FONT SIZES
  final TextStyle body = const TextStyle(fontSize: 20.0);
  final TextStyle small = const TextStyle(fontSize: 14.0);
  final TextStyle bigger = const TextStyle(fontSize: 24.0);
  final TextStyle title = const TextStyle(fontSize: 32.0);

  // FONT WEIGHTS
  final TextStyle regular = const TextStyle(fontWeight: FontWeight.w400);
  final TextStyle bold = const TextStyle(fontWeight: FontWeight.w700);

  // TEXT COLORS
  final TextStyle black = TextStyle(color: const AppColors().black);
  final TextStyle cornflower = TextStyle(color: const AppColors().cornflower);
  final TextStyle error = TextStyle(color: const AppColors().error);
  final TextStyle grey = TextStyle(color: const AppColors().grey);
  final TextStyle orchid = TextStyle(color: const AppColors().orchid);
  final TextStyle turquoise = TextStyle(color: const AppColors().turquoise);
  final TextStyle white = TextStyle(color: const AppColors().white);

  // TEXT DECORATION
  final TextStyle underlined =
      const TextStyle(decoration: TextDecoration.underline);
  final TextStyle spacedLetters = const TextStyle(letterSpacing: 1);

  AppThemes();
}
