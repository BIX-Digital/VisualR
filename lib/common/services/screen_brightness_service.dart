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

import 'package:screen_brightness/screen_brightness.dart';
import 'package:visualr_app/meta.dart';

class ScreenBrightnessService {
  double desiredBrightness;

  ScreenBrightnessService({
    this.desiredBrightness = 0.6,
  });

  factory ScreenBrightnessService.fromView(UnityView view) {
    final double desiredBrightness = switch (view) {
      UnityView.contrastDark => 0.6,
      UnityView.contrastLight => 0.3,
      _ => 0.6,
    };
    return ScreenBrightnessService(desiredBrightness: desiredBrightness);
  }

  Future<void> setBrightness() async {
    ScreenBrightness().setScreenBrightness(desiredBrightness);
  }

  void resetBrightness() {
    ScreenBrightness().resetScreenBrightness();
  }

  Future<double> get brightness => ScreenBrightness().current;
}
