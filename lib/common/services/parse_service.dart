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

class ParseService {
  static Duration duration(String s) {
    final List<String> parts = s.split(':');
    final int minutes = int.parse(parts[parts.length - 2]);
    final int milliseconds =
        (double.parse(parts[parts.length - 1]) * 1000).round();
    return Duration(minutes: minutes, milliseconds: milliseconds);
  }

  static T? tryCast<T>(dynamic value) => value is T ? value : null;

  static T cast<T>(dynamic value, String variableName) {
    final T? castValue = tryCast<T>(value);
    if (castValue == null) {
      throw FormatException(
        'Invalid data: $value -> "$variableName" is missing or incorrectly typed',
      );
    }
    return castValue;
  }

  static List<T> castList<T>(dynamic list, String listName) {
    final List<dynamic> castList = cast<List<dynamic>>(list, listName);
    return castList
        .map((element) => cast<T>(element, "$listName.element"))
        .toList();
  }
}
