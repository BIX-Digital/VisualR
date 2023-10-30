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

import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualr_app/common.dart';
import 'package:visualr_app/common/database/objectbox.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/routes/router.dart';
import 'package:visualr_app/routes/router.gr.dart';
import 'package:visualr_app/theme/colors.dart';
import 'package:visualr_app/theme/themes.dart';

late ObjectBox objectBox;
double minVolume = 0.5;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.create();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then(
    (_) => SharedPreferences.getInstance().then(
      (prefs) => runApp(
        ChangeNotifierProvider.value(
          value: Prefs(prefs),
          child: const AppWidget(),
        ),
      ),
    ),
  );
}

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  final _appRouter = AppRouter();
  double _volume = 0.0;

  void _setVolumeToAtLeastMinimumValue(double volume) {
    setState(() {
      _volume = volume < minVolume ? minVolume : volume;
    });
    PerfectVolumeControl.setVolume(_volume);
  }

  @override
  void initState() {
    PerfectVolumeControl.getVolume()
        .then((volume) => _setVolumeToAtLeastMinimumValue(volume));
    PerfectVolumeControl.stream
        .listen((volume) => _setVolumeToAtLeastMinimumValue(volume));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Prefs>(
      builder: (context, prefs, child) => MaterialApp.router(
        routerDelegate: _appRouter.delegate(
          navigatorObservers: () => [AutoRouteObserver()],
          deepLinkBuilder: (deepLink) => !prefs.isOnboard
              ? const DeepLink([OnboardingRoute()])
              : const DeepLink([HomeRoute()]),
        ),
        routeInformationParser: _appRouter.defaultRouteParser(),
        theme: ThemeData(
          colorScheme: const ColorScheme.light().copyWith(
            primary: const AppColors().black,
          ),
          fontFamily: 'Sora',
          cardTheme: AppThemes().card,
          dialogTheme: AppThemes().dialog,
          elevatedButtonTheme: AppThemes().elevatedButton,
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedLocales.map((locale) => Locale(locale)),
        locale: Locale(prefs.locale),
      ),
    );
  }
}
