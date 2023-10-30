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
import 'dart:math' as math;

import 'package:visualr_app/common/models/coordinates.dart';
import 'package:visualr_app/distortion/models/orientation.dart';
import 'package:visualr_app/distortion/models/processed_name.dart';
import 'package:visualr_app/meta.dart';

Map<String, List<String>> bins = {
  'b0_h_l': ['0_h_l', '1_h_l', '2_h_l'],
  'b1_h_l': ['3_h_l', '4_h_l', '5_h_l'],
  'b2_h_l': ['6_h_l', '7_h_l', '8_h_l'],
  'b0_h_r': ['0_h_r', '1_h_r', '2_h_r'],
  'b1_h_r': ['3_h_r', '4_h_r', '5_h_r'],
  'b2_h_r': ['6_h_r', '7_h_r', '8_h_r'],
  'b0_v_l': ['0_v_l', '1_v_l', '2_v_l'],
  'b1_v_l': ['3_v_l', '4_v_l', '5_v_l'],
  'b2_v_l': ['6_v_l', '7_v_l', '8_v_l'],
  'b0_v_r': ['0_v_r', '1_v_r', '2_v_r'],
  'b1_v_r': ['3_v_r', '4_v_r', '5_v_r'],
  'b2_v_r': ['6_v_r', '7_v_r', '8_v_r'],
};

Map<int, double> lengthLookup = {
  0: 300,
  1: 480,
  2: 600,
  3: 720,
  4: 720,
  5: 720,
  6: 600,
  7: 480,
  8: 300,
};

double getDotSpacing(num id) {
  return 6.0 + 6.0 * id;
}

List<double> possibleFixedCoordinates =
    List.generate(9, (index) => -360.0 + 90.0 * index);

class Line {
  String name;
  late int id;
  late DateTime createdAt;
  late DateTime answerGivenAt;
  late Orientation orientation;
  late EyeEnum eye;
  int dotSpacingId;
  List<Coordinates> coordinates = [];
  late double length;
  late double dotSpacing;
  bool? answer;
  bool distorted;

  Line({
    required this.name,
    this.distorted = false,
    this.dotSpacingId = 0,
    this.answer,
  }) {
    final ProcessedName processedName = processName(name);
    id = processedName.id;
    orientation = processedName.orientation;
    eye = processedName.eye;
    length = getLength(id);
    dotSpacing = getDotSpacing(dotSpacingId);
    coordinates = calculateCoordinates(dotSpacing, length, orientation);
  }

  bool get isCentralLine => ["1", "4", "7"].contains(name[0]);

  String get bin => bins.keys.firstWhere((bin) => bins[bin]!.contains(name));

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'answerGivenAt': answerGivenAt.millisecondsSinceEpoch,
      'orientation': orientation.toShortString(),
      'eye': eye.toShortString(),
      'dotSpacingId': dotSpacingId,
      'dotSpacing': dotSpacing,
      'length': length,
      'coordinates':
          coordinates.map((coordinate) => coordinate.toJson()).toList(),
      'answer': answer,
    };
  }

  Map<String, dynamic> toUnityJson() {
    return {
      'eye': eye.toShortString(),
      'coordinates': coordinates,
    };
  }

  @override
  String toString({bool unity = false}) {
    return unity ? json.encode(toUnityJson()) : json.encode(toJson());
  }

  ProcessedName processName(String name) {
    final List<String> lineVariables = name.split('_');
    return ProcessedName(
      id: int.parse(lineVariables[0]),
      orientation: lineVariables[1] == 'h'
          ? Orientation.horizontal
          : Orientation.vertical,
      eye: lineVariables[2] == 'l' ? EyeEnum.left : EyeEnum.right,
    );
  }

  double getLength(int id) {
    final double? length = lengthLookup[id];
    if (length == null) {
      throw FormatException(
        'Invalid data: $id -> "id" needs to be between 0 and 8',
      );
    }
    return length;
  }

  double getFixedCoordinate(int id) {
    return possibleFixedCoordinates[id];
  }

  List<Coordinates> distortLine({
    required double fixedCoordinate,
    required List<double> dynamicCoordinates,
  }) {
    const int minAmplitude = 10;
    const int maxAmplitude = 20;
    const double minProportion = 0.2;
    const double maxProportion = 0.3;
    const List<int> possibleWaveLengths = [2, 3, 4];
    final random = math.Random();
    final int amplitude =
        minAmplitude + random.nextInt(maxAmplitude - minAmplitude);
    final double proportion =
        minProportion + random.nextDouble() * (maxProportion - minProportion);
    final int waveLength = (possibleWaveLengths.toList()..shuffle()).first;
    final int numberOfDistortedCoordinates =
        (dynamicCoordinates.length * proportion).round();
    final int firstDistortedCoordinateIndex = random
        .nextInt(dynamicCoordinates.length - numberOfDistortedCoordinates);
    final int lastDistortedCoordinateIndex =
        firstDistortedCoordinateIndex + numberOfDistortedCoordinates;
    final double lineLength = dynamicCoordinates[lastDistortedCoordinateIndex] -
        dynamicCoordinates[firstDistortedCoordinateIndex];
    return dynamicCoordinates.asMap().entries.map((dynamicCoordinate) {
      double newFixedCoordinate = fixedCoordinate;
      if (dynamicCoordinate.key >= firstDistortedCoordinateIndex &&
          dynamicCoordinate.key <= lastDistortedCoordinateIndex) {
        newFixedCoordinate = fixedCoordinate +
            amplitude *
                math.sin(
                  waveLength *
                      math.pi *
                      (dynamicCoordinate.value -
                          dynamicCoordinates[firstDistortedCoordinateIndex]) /
                      lineLength,
                );
      }
      return orientation == Orientation.horizontal
          ? Coordinates(
              x: dynamicCoordinate.value,
              y: newFixedCoordinate,
            )
          : Coordinates(
              x: newFixedCoordinate,
              y: dynamicCoordinate.value,
            );
    }).toList();
  }

  List<Coordinates> calculateCoordinates(
    double dotSpacing,
    double length,
    Orientation orientation,
  ) {
    int numberOfPoints = (length / dotSpacing).floor();
    // if adding one points more, the length does not increase more than 30%, then add the point
    if ((numberOfPoints + 1) * dotSpacing <= length * 1.3) {
      numberOfPoints++;
    }
    final double maxCoordinate = 0.5 * dotSpacing * (numberOfPoints - 1);
    final List<double> dynamicCoordinates = List.generate(
      numberOfPoints,
      (index) => double.parse(
        (-maxCoordinate + index * dotSpacing).toStringAsFixed(2),
      ),
    );
    if (distorted) {
      return distortLine(
        fixedCoordinate: getFixedCoordinate(id),
        dynamicCoordinates: dynamicCoordinates,
      );
    }
    final List<Coordinates> coordinates =
        List.generate(numberOfPoints, (index) {
      return orientation == Orientation.horizontal
          ? Coordinates(
              x: dynamicCoordinates[index],
              y: getFixedCoordinate(id),
            )
          : Coordinates(
              x: getFixedCoordinate(id),
              y: dynamicCoordinates[index],
            );
    });
    return coordinates;
  }
}
