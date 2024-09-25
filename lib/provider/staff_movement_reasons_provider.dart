import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/staff_movement_repository.dart';

final staffMovementReasonProvider = StreamProvider<List<String>>((ref) async* {
  final api = StaffMovementReasonRepository();
  try {
    final reasons = await api.getStaffMovementReasons();
    yield reasons;
  } catch (e) {
    // Handle network errors or exceptions here
    yield* Stream.error(e);
  }
});
