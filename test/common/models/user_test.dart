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

import 'package:flutter_test/flutter_test.dart';
import 'package:visualr_app/common/models/user.dart';

void main() {
  final String userId = generateUserId();
  final User user = User(
    displayName: 'User',
    id: userId,
  );
  final Map<String, dynamic> json = {
    "displayName": "User",
    "id": userId,
  };
  group('User', () {
    test('should parse JSON', () {
      final User user = User.fromJson(json);
      expect(user.displayName, 'User');
      expect(user.id, userId);
    });
    test('should generate unique IDs for the same user display name', () {
      final User firstUser = User.generateId('User');
      final User secondUser = User.generateId('User');
      expect(firstUser.id, isNot(secondUser.id));
    });
    test('should be convertible to JSON', () {
      expect(user.toJson(), json);
    });
  });
}
