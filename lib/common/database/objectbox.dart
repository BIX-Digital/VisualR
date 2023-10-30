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

import 'package:visualr_app/contrast/database/contrast.repository.dart';
import 'package:visualr_app/contrast/models/test.model.dart';
import 'package:visualr_app/distortion/database/distortion.repository.dart';
import 'package:visualr_app/distortion/models/test.model.dart';
import 'package:visualr_app/ipda/database/ipda.repository.dart';
import 'package:visualr_app/ipda/models/ipda.model.dart';
import 'package:visualr_app/objectbox.g.dart';
import 'package:visualr_app/reading_speed/database/reading_speed.repository.dart';
import 'package:visualr_app/reading_speed/models/sequence.model.dart';

/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class ObjectBox {
  late final Store store;

  late final Box<ContrastTestEntity> _contrastBox;
  late final Box<DistortionTestEntity> _distortionBox;
  late final Box<ReadingSpeedTestSequenceEntity> _readingSpeedBox;
  late final Box<IPDAEntity> _ipdaBox;

  late final ContrastTestRepository contrast;
  late final IPDARepository ipda;
  late final DistortionTestSequenceRepository distortion;
  late final ReadingSpeedTestSequenceRepository readingSpeed;

  void _initializeRepositories() {
    contrast = ContrastTestRepository(box: _contrastBox);
    ipda = IPDARepository(box: _ipdaBox);
    distortion = DistortionTestSequenceRepository(box: _distortionBox);
    readingSpeed = ReadingSpeedTestSequenceRepository(box: _readingSpeedBox);
  }

  ObjectBox._create(this.store) {
    _contrastBox = Box<ContrastTestEntity>(store);
    _ipdaBox = Box<IPDAEntity>(store);
    _distortionBox = Box<DistortionTestEntity>(store);
    _readingSpeedBox = Box<ReadingSpeedTestSequenceEntity>(store);
    _initializeRepositories();
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create({String? directory}) async {
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: directory);
    return ObjectBox._create(store);
  }
}
