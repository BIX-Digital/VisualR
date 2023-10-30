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

import 'package:visualr_app/common/models/user.dart';

final User user = User(
  displayName: 'User',
  id: 'user_id',
);

final DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(0);

final DateTime answerGivenAt = DateTime.fromMillisecondsSinceEpoch(0);
