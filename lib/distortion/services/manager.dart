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

import 'package:visualr_app/distortion/models/binary_search.dart';
import 'package:visualr_app/distortion/models/line.dart';
import 'package:visualr_app/distortion/models/summary.dart';

class DistortionManager {
  final List<Line> _firstPartLines = [];
  List<BinarySearch>? _binarySearches;
  final List<Line> _secondPartLines = [];
  final List<String> _missedFirstPartLines = [];
  final Map<String, List<int?>> _scores = {};
  late Line _current;
  final Random random = Random();
  bool isPresentation;

  DistortionManager({
    this.isPresentation = false,
  });

  static Future<DistortionManager> startManager({
    bool isPresentation = false,
  }) async {
    final manager = DistortionManager(
      isPresentation: isPresentation,
    );
    manager._generateFirstPartLines();
    manager._firstPartLines.shuffle();
    final Line? currentTest = await manager.createTestEvent();
    if (currentTest != null) {
      manager._current = currentTest;
    }
    return manager;
  }

  void _generateFirstPartLines() {
    if (isPresentation) {
      _generatePossibleLineIdentifiers().take(10).forEach(
            (lineIdentifier) => _firstPartLines.add(Line(name: lineIdentifier)),
          );
      _addDistortedLines(numberOfLines: 2);
      return;
    }
    _generatePossibleLineIdentifiers().forEach(
      (lineIdentifier) => _firstPartLines.add(Line(name: lineIdentifier)),
    );
    _addDistortedLines();
  }

  void _addDistortedLines({int numberOfLines = 4}) {
    final List<Line> linesToAdd = [
      Line(
        name:
            _firstPartLines.firstWhere((line) => line.name.contains('l')).name,
        distorted: true,
      ),
      Line(
        name:
            _firstPartLines.firstWhere((line) => line.name.contains('r')).name,
        distorted: true,
      ),
      Line(
        name: _firstPartLines.lastWhere((line) => line.name.contains('l')).name,
        distorted: true,
      ),
      Line(
        name: _firstPartLines.lastWhere((line) => line.name.contains('r')).name,
        distorted: true,
      ),
    ];
    _firstPartLines.addAll(linesToAdd.take(numberOfLines));
  }

  Future<Line?> createTestEvent() async {
    Line? line;
    if (isSecondPart) {
      if (isPresentation) return null;
      _binarySearches ??= _decideLinesToFollow();
      line = _getNextLineFromBinarySearch(_binarySearches!);
      if (line != null) {
        _current = line;
      }
      return line;
    }
    line = _firstPartLines[
        _firstPartLines.where((line) => line.answer != null).length];
    _current = line;
    return line;
  }

  List<BinarySearch> _decideLinesToFollow() {
    final List<BinarySearch> binarySearches = [];
    if (firstPartLinesSeenDistorted.length > 12) {
      final List<Line> linesToFollow = [];
      final List<String> activeBins = [];
      linesToFollow.addAll(
        firstPartLinesSeenDistorted.where((line) => line.isCentralLine),
      );
      // get the bins with active lines and no central lines
      activeBins.addAll(
        firstPartLinesSeenDistorted
            .map((line) => line.bin)
            .toSet()
            .difference(linesToFollow.map((line) => line.bin).toSet()),
      );
      // choose a random line for these bins
      for (final String bin in activeBins) {
        linesToFollow.add(
          Line(name: bins[bin]![random.nextInt(bins[bin]!.length)]),
        );
      }
      // if the lines chosen up to now are less than 12, pick randomly other lines
      for (int i = linesToFollow.length; i < 12; i++) {
        final List<Line> linesNotYetFollowed = firstPartLinesSeenDistorted
            .toSet()
            .difference(linesToFollow.toSet())
            .toList();
        linesToFollow.add(
          linesNotYetFollowed[random.nextInt(linesNotYetFollowed.length)],
        );
      }
      assert(linesToFollow.length == 12);
      // if line is active and we want to follow it in the 2nd part of test, create a binary search
      for (final Line line in firstPartLinesSeenDistorted) {
        if (linesToFollow
            .map((line) => line.name)
            .toList()
            .contains(line.name)) {
          binarySearches.add(BinarySearch(line: line.name));
        } else {
          // this is indistinguishable from line not seen as distorted
          _scores[line.name] = [0, null];
        }
      }
      return binarySearches;
    }
    for (final Line line in firstPartLinesSeenDistorted) {
      binarySearches.add(BinarySearch(line: line.name));
    }
    return binarySearches;
  }

  Line? _getNextLineFromBinarySearch(List<BinarySearch> binarySearches) {
    if (binarySearches.isEmpty) return null;
    final BinarySearch randomBinarySearch =
        binarySearches[random.nextInt(binarySearches.length)];
    return Line(
      name: randomBinarySearch.line,
      dotSpacingId: randomBinarySearch.dotSpacingId - 1,
    );
  }

  void _updateBinarySearch(Line line, bool answer) {
    final BinarySearch binarySearch = _binarySearches!
        .firstWhere((binarySearch) => binarySearch.line == line.name);
    answer
        ? binarySearch.upperLimit = binarySearch.dotSpacingId
        : binarySearch.lowerLimit = binarySearch.dotSpacingId;
    if (binarySearch.finished) {
      // add the score
      int score = getDotSpacing(binarySearch.upperLimit - 1).toInt();
      score = score == 6 ? 0 : score;
      if (_scores[binarySearch.line] == null) {
        _scores[binarySearch.line] = [score];
      } else {
        _scores[binarySearch.line]!.add(score);
      }
      // remove the entry
      _binarySearches!.removeWhere(
        (binarySearch) => binarySearch.line == line.name,
      );
      // if the entry for the current line has 2 scores already, it means this was the 2nd binary search
      if (_scores[binarySearch.line]!.length == 2) return;
      _binarySearches!.add(BinarySearch(line: line.name));
      return;
    }
    binarySearch.dotSpacingId =
        (binarySearch.lowerLimit + binarySearch.upperLimit) ~/ 2;
  }

  DistortionSummary _calculateSummaryScores() {
    final Map<String, double> calculatedScores = Map.fromEntries(
      _scores.entries.map((score) {
        double calculatedScore = 0;
        if (score.value.last != null) {
          calculatedScore = 0.5 * (score.value.first! + score.value.last!);
        }
        return MapEntry(score.key, calculatedScore);
      }),
    );

    return DistortionSummary.fromScores(calculatedScores);
  }

  List<String> _generatePossibleLineIdentifiers() {
    final List<String> possibleIdentifiers = [];
    for (int id = 0; id < 9; id++) {
      for (int orientation = 0; orientation < 2; orientation++) {
        for (int eye = 0; eye < 2; eye++) {
          possibleIdentifiers.add(
            '${id}_${orientation == 0 ? 'v' : 'h'}_${eye == 0 ? 'l' : 'r'}',
          );
        }
      }
    }
    possibleIdentifiers.shuffle();
    return possibleIdentifiers;
  }

  bool get isSecondPart => _firstPartLines.every((line) => line.answer != null);

  Line get current => _current;

  Map<String, List<int?>> get scores => _scores;

  DistortionSummary get summary => _calculateSummaryScores();

  List<Line> get firstPartLines => _firstPartLines;

  List<Line> get firstPartLinesDistorted =>
      _firstPartLines.where((line) => line.distorted).toList();

  List<Line> get firstPartLinesStraight =>
      _firstPartLines.where((line) => !line.distorted).toList();

  List<Line> get firstPartLinesSeenDistorted => _firstPartLines
      .where((line) => !line.distorted && line.answer == false)
      .toList();

  List<Line> get firstPartLinesSeenStraight => _firstPartLines
      .where((line) => !line.distorted && line.answer == true)
      .toList();

  List<Line> get secondPartLines => _secondPartLines;

  List<String> get missedFirstPartLines => _missedFirstPartLines;

  List<BinarySearch>? get binarySearches => _binarySearches;

  void updateTestResults({bool? answer}) {
    if (isSecondPart) {
      _current.answer = answer ?? true;
      final Line lineToAdd = Line(
        name: _current.name,
        dotSpacingId: _current.dotSpacingId,
        answer: answer,
      );
      lineToAdd.answerGivenAt = _current.answerGivenAt;
      lineToAdd.createdAt = _current.createdAt;
      _secondPartLines.add(lineToAdd);
      _updateBinarySearch(_current, _current.answer!);
      return;
    }
    if (answer == null) {
      _missedFirstPartLines.add(_current.name);
    }
    _current.answer = answer ?? true;
    if (_current.answer == true && !_current.distorted) {
      _scores[_current.name] = [0, null];
    }
  }
}
