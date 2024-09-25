import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hng_flutter/data/opeartions/store_transfer_entity.dart';
import 'package:hng_flutter/provider/week_off_provider.dart';

import '../repository/store_transfer_respository.dart';




final employeeCodeProviderStoreTransfer = StateProvider<String>((ref) => "");


final storeTransferProvider = StreamProvider<StoreTransferData?>((ref) async* {
  final repository = StoreTransferRepository();
  final employeeCode = ref.watch(employeeCodeProviderStoreTransfer);

  try {
    StoreTransferData? storeTransferData =
        await repository.getStoreTransferData(employeeCode);
    yield storeTransferData;
  } catch (e) {
    yield* Stream.error(e);
  }
});
