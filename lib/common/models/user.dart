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
import 'dart:math';

String generateUserId() {
  final Random r = Random();
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(32, (index) => chars[r.nextInt(chars.length)]).join();
}

class User {
  String id;
  String displayName;
  User({
    required this.id,
    required this.displayName,
  });

  factory User.generateId(String name) {
    return User(
      id: generateUserId(),
      displayName: name,
    );
  }

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String,
      displayName: data['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
