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

import 'package:visualr_app/common/database/repository.dart';
import 'package:visualr_app/distortion/models/test.dart';
import 'package:visualr_app/distortion/models/test.model.dart';
import 'package:visualr_app/objectbox.g.dart';

class DistortionTestSequenceRepository
    extends Repository<DistortionTestEntity> {
  DistortionTestSequenceRepository({required super.box});
  int save({required DistortionTest test}) {
    return box.put(DistortionTestEntity.fromDTO(test: test));
  }

  bool delete({int? id}) {
    if (id == null) {
      final queryBuilder = box.query()
        ..order(
          DistortionTestEntity_.createdAt,
          flags: Order.descending,
        );
      final query = queryBuilder.build();
      final DistortionTestEntity? sequence = query.findFirst();
      if (sequence == null) {
        return false;
      }
      return box.remove(sequence.id);
    }
    return box.remove(id);
  }

  @override
  List<DistortionTestEntity> getAll() {
    return box.getAll();
  }
}
