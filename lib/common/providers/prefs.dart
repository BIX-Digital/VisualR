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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/common/models/user.dart';

List<String> supportedLocales = ['en', 'de'];
String defaultLocale = 'en';

class Prefs extends ChangeNotifier {
  SharedPreferences prefs;

  Prefs(this.prefs);

  String _getDefaultLocale() {
    final String deviceLocale = Platform.localeName.substring(0, 2);
    final isLocaleSupported = supportedLocales.contains(deviceLocale);
    return isLocaleSupported ? deviceLocale : defaultLocale;
  }

  bool get seenInstructions {
    return prefs.getBool('seenInstructions') ?? false;
  }

  set seenInstructions(bool seenInstructions) {
    prefs.setBool('seenInstructions', seenInstructions);
    notifyListeners();
  }

  String get locale {
    return prefs.getString('locale') ?? _getDefaultLocale();
  }

  set locale(String locale) {
    prefs.setString('locale', locale);
    notifyListeners();
  }

  User get user {
    final String? userString = prefs.getString('user');
    return userString != null
        ? User.fromJson(json.decode(userString) as Map<String, dynamic>)
        : User(id: 'user_id', displayName: 'user_name');
  }

  set user(User user) {
    prefs.setString('user', user.toString());
    notifyListeners();
  }

  Set<String> get finishedTests {
    return prefs.getStringList('finishedTests')?.toSet() ?? <String>{};
  }

  set finishedTests(Set<String> finishedTests) {
    prefs.setStringList('finishedTests', finishedTests.toList());
    notifyListeners();
  }

  bool get isOnboard {
    return prefs.getBool('isOnboard') ?? false;
  }

  set isOnboard(bool isOnboard) {
    prefs.setBool('isOnboard', isOnboard);
    notifyListeners();
  }

  double get ipd {
    return prefs.getDouble('ipd') ?? 0;
  }

  set ipd(double ipd) {
    prefs.setDouble('ipd', ipd);
    notifyListeners();
  }

  double get screenToLensDistance {
    // estimated screen to lens distance for the Destek headset: 43mm
    return prefs.getDouble('screenToLensDistance') ?? 43.0;
  }

  set screenToLensDistance(double screenToLensDistance) {
    prefs.setDouble('screenToLensDistance', screenToLensDistance);
    notifyListeners();
  }

  bool get debug {
    return user.displayName.toLowerCase().contains("debug");
  }

  bool get presentation {
    return user.displayName.toLowerCase().contains("presentation");
  }

  Future<bool> clear() {
    return prefs.clear().then((value) {
      notifyListeners();
      return true;
    }).catchError((_) => false);
  }
}
