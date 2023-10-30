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
import 'package:visualr_app/common/models/display_size.dart';
import 'package:visualr_app/ipda/models/answers.dart';
import 'package:visualr_app/ipda/models/ipda.dart';

import '../data.dart';

const double ipd = 58.59375;

final DisplaySize displaySize = DisplaySize(
  height: 1920,
  width: 1080,
  dpi: 460,
);

final AppMeta appMeta = AppMeta(
  appVersion: '1.0.0',
  buildNumber: '1',
  locale: 'en',
  device: 'iPhone 12,1',
);

final IPDAAnswers answers = IPDAAnswers(
  raw: [2, 3, 2, 3],
  decoded: [6, 7, 5, 7],
);

final IPDA ipda = IPDA(
  createdAt: createdAt,
  user: user,
  displaySize: displaySize,
  answers: answers,
  ipd: ipd,
  appMeta: appMeta,
);
