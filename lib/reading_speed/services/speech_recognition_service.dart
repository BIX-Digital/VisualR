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

import 'dart:math';

class SpeechRecognitionService {
  int levenshtein(String term1, String term2) {
    if (term1.isEmpty || term2.isEmpty) return 0;
    final m = term1.length + 1;
    final n = term2.length + 1;
    final tmp = List.filled(n - 1, 0);
    final d = List.generate(
      m,
      (i) => (i == 0) ? List.generate(n, (j) => j) : [i, ...tmp],
    );
    for (var i = 1; i < m; ++i) {
      for (var j = 1; j < n; ++j) {
        final cost =
            (term1[i - 1].toLowerCase() == term2[j - 1].toLowerCase()) ? 0 : 1;
        d[i][j] = min(
          min(d[i - 1][j] + 1, d[i][j - 1] + 1),
          d[i - 1][j - 1] + cost,
        );
      }
    }
    return d[m - 1][n - 1];
  }

  double characterErrorRate(String s1, String s2) {
    // Calculate the Levenshtein distance between the two strings
    final int distance = levenshtein(s1, s2);

    // Calculate the CER by dividing the distance by the length of the reference string
    return distance / s1.length;
  }

  double wordErrorRate(String s1, String s2) {
    // Split the strings into lists of words
    final List<String> words1 = s1.split(" ");
    final List<String> words2 = s2.split(" ");

    // Initialize a matrix with the lengths of the two lists as the dimensions
    final List<List<int>> matrix = List.generate(
      words1.length + 1,
      (_) => List.filled(words2.length + 1, 0),
    );

    // Fill the first row and column with values from 0 to the length of the list
    for (int i = 0; i <= words1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= words2.length; j++) {
      matrix[0][j] = j;
    }

    // Iterate through the matrix and fill in the values using the Levenshtein distance formula
    for (int i = 1; i <= words1.length; i++) {
      for (int j = 1; j <= words2.length; j++) {
        final int cost =
            (words1[i - 1].toLowerCase() == words2[j - 1].toLowerCase())
                ? 0
                : 1;
        matrix[i][j] = min(
          matrix[i - 1][j] + 1,
          min(matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost),
        );
      }
    }

    // Return the value in the bottom-right corner of the matrix
    return matrix[words1.length][words2.length] / words1.length;
  }
}
