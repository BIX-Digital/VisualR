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

import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:visualr_app/common/models/coordinates.dart';
import 'package:visualr_app/contrast/models/color.dart';
import 'package:visualr_app/contrast/models/result.dart';
import 'package:visualr_app/contrast/models/step.dart';
import 'package:visualr_app/contrast/models/summary.dart';
import 'package:visualr_app/contrast/services/presentation_service.dart';
import 'package:visualr_app/contrast/services/staircase_handler.dart';
import 'package:visualr_app/meta.dart';

class ContrastManager {
  final List<ContrastStep> _steps = [];
  late ContrastStep _current;
  late StaircaseHandler _leftEyeStaircase;
  late StaircaseHandler _rightEyeStaircase;
  ContrastSummary? _summary;
  final bool darkBackground;
  ContrastPresentationService? presentationService;

  static Future<ContrastManager> startManager({
    bool isPresentation = false,
    bool darkBackground = true,
  }) async {
    ContrastPresentationService? presentationService;
    if (isPresentation) {
      presentationService = darkBackground
          ? ContrastPresentationService.dark()
          : ContrastPresentationService.light();
    }
    final manager = ContrastManager(
      darkBackground: darkBackground,
      presentationService: presentationService,
    );
    final ContrastStep? currentTest = await manager.createTestEvent();
    if (currentTest != null) {
      manager._current = currentTest;
    }
    return manager;
  }

  ContrastManager({
    this.darkBackground = true,
    this.presentationService,
  }) {
    _leftEyeStaircase = StaircaseHandler(darkBackground: darkBackground);
    _rightEyeStaircase = StaircaseHandler(darkBackground: darkBackground);
  }

  Future<ContrastStep?> createTestEvent() async {
    if (presentationService != null) {
      if (_steps.length == presentationService!.steps.length) {
        return null;
      }
      final ContrastStep step = presentationService!.steps[_steps.length];
      _steps.add(step);
      _current = step;
      return step;
    }
    if (isFinished) {
      _summary = ContrastSummary(
        left: _leftEyeStaircase.getSummary(),
        right: _rightEyeStaircase.getSummary(),
      );
      return null;
    }
    final test = _getNextTestEvent();
    if (test == null) {
      return createTestEvent();
    }
    _steps.add(test);
    _current = test;
    return test;
  }

  ContrastStep createTestWithDifferentRingNum() {
    final possibleNumberOfRings = [1, 2, 7];
    possibleNumberOfRings.shuffle();
    final List<Coordinates> coordinates =
        getCoordinates(possibleNumberOfRings.first);
    final EyeEnum eye =
        EyeEnum.values[math.Random().nextInt(EyeEnum.values.length)];

    final ContrastStep test = ContrastStep(
      color: darkBackground
          ? const Color(r: 45, g: 45, b: 45)
          : const Color(r: 102, g: 102, b: 102),
      coordinates: coordinates,
      contrastSensitivity: null,
      eye: eye,
      result: ContrastResult(
        numDisplayed: coordinates.length,
        numSeen: 0,
      ),
      step: _steps.length + 1,
      isFake: true,
    );
    _steps.add(test);
    _current = test;
    return test;
  }

  ContrastStep? _getNextTestEvent() {
    final List<Coordinates> coordinates =
        getCoordinates(3 + math.Random().nextInt(4));
    final EyeEnum eye = _getEye();
    final StaircaseHandler staircaseHandler =
        eye == EyeEnum.left ? _leftEyeStaircase : _rightEyeStaircase;
    final ContrastStep? lastStepForEye =
        steps.lastWhereOrNull((step) => !step.isFake && step.eye == eye);
    final double percentageSeenLastStep = lastStepForEye != null
        ? (lastStepForEye.result!.numSeen / lastStepForEye.result!.numDisplayed)
        : 0.0;
    final Color nextColor =
        staircaseHandler.getNextColor(percentageSeenLastStep);
    if (staircaseHandler.isFinished) return null;
    return ContrastStep(
      step: _steps.length + 1,
      eye: eye,
      color: nextColor,
      contrastSensitivity: staircaseHandler.contrast,
      coordinates: coordinates,
    );
  }

  List<Coordinates> getCoordinates(int numberOfCircles) {
    // Create a copy of the possible coordinates to list to be able to shuffle it
    final List<Coordinates> possibleCoordinates = contrastCoordinates.toList();
    // We shuffle the list of coordinates so that the order of the coordinates is random
    possibleCoordinates.shuffle();
    final List<Coordinates> coordinates = [];
    for (int i = 0; i < numberOfCircles; i++) {
      coordinates.add(
        Coordinates.getCoordinates(possibleCoordinates, i),
      );
    }
    return coordinates;
  }

  EyeEnum _getEye() {
    final List<EyeEnum> staircasesStillOpen = [];
    if (!_leftEyeStaircase.isFinished) {
      staircasesStillOpen.add(EyeEnum.left);
    }
    if (!_rightEyeStaircase.isFinished) {
      staircasesStillOpen.add(EyeEnum.right);
    }
    staircasesStillOpen.shuffle();
    return staircasesStillOpen.first;
  }

  void updateTestResults({required int answer}) {
    _current.answerGivenAt = DateTime.now();
    _current.result = ContrastResult(
      numDisplayed: _current.coordinates.length,
      numSeen: answer,
    );
  }

  ContrastStep get current => _current;

  List<ContrastStep> get steps => _steps;

  ContrastSummary? get summary => _summary;

  bool get isFinished =>
      _leftEyeStaircase.isFinished && _rightEyeStaircase.isFinished;
}

List<Coordinates> contrastCoordinates = [
  Coordinates(x: 157, y: 135),
  Coordinates(x: 130, y: 0),
  Coordinates(x: 16, y: 106),
  Coordinates(x: -151, y: 126),
  Coordinates(x: -157, y: -106),
  Coordinates(x: -13, y: -126),
  Coordinates(x: -72, y: 0),
];
