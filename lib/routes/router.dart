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
import 'package:visualr_app/routes/router.gr.dart';

List<AutoRoute> homeRoutes = [
  AutoRoute(
    path: '',
    page: HomeRoute.page,
  ),
];

List<AutoRoute> settingsRoutes = [
  AutoRoute(
    path: 'settings',
    page: SettingsRouter.page,
    children: <AutoRoute>[
      AutoRoute(
        path: '',
        page: SettingsRoute.page,
      ),
      AutoRoute(
        path: 'licenses',
        page: LicensesRouter.page,
        children: <AutoRoute>[
          AutoRoute(
            path: '',
            page: LicensesRoute.page,
          ),
          AutoRoute(
            path: ':id',
            page: LicenseDetailRoute.page,
          ),
        ],
      ),
    ],
  ),
];

List<AutoRoute> unityRoutes = [
  AutoRoute(
    path: 'unity',
    page: UnityRouter.page,
    children: <AutoRoute>[
      AutoRoute(
        path: 'distortion',
        page: UnityDistortionRoute.page,
      ),
      AutoRoute(
        path: 'contrast',
        page: UnityContrastRoute.page,
      ),
      AutoRoute(
        path: 'readingSpeed',
        page: UnityReadingSpeedRoute.page,
      ),
      AutoRoute(
        path: 'settings',
        page: UnitySettingsRoute.page,
      ),
      AutoRoute(
        path: 'ipda',
        page: UnityIPDARoute.page,
      ),
      AutoRoute(
        path: 'readingSpeedInstructions',
        page: ReadingSpeedInstructionsRoute.page,
      ),
    ],
  ),
];

List<AutoRoute> onboardingRoutes = [
  AutoRoute(
    path: 'onboarding',
    page: OnboardingRouter.page,
    children: <AutoRoute>[
      AutoRoute(
        path: '',
        page: OnboardingRoute.page,
      ),
      AutoRoute(
        path: 'ipda',
        page: IPDATaskRoute.page,
      ),
    ],
  ),
];

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      path: '/',
      page: HomeRouter.page,
      children: [
        ...homeRoutes,
        ...settingsRoutes,
        ...unityRoutes,
        ...onboardingRoutes,
      ],
    ),
  ];
}

@RoutePage(name: 'HomeRouter')
class HomeRouterPage extends AutoRouter {}

@RoutePage(name: 'UnityRouter')
class UnityRouterPage extends AutoRouter {}

@RoutePage(name: 'SettingsRouter')
class SettingsRouterPage extends AutoRouter {}

@RoutePage(name: 'LicensesRouter')
class LicensesRouterPage extends AutoRouter {}

@RoutePage(name: 'OnboardingRouter')
class OnboardingRouterPage extends AutoRouter {}
