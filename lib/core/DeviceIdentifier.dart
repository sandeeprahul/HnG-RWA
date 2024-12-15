import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentifier {
  static const _storage = FlutterSecureStorage();
  static const _key = 'device_unique_id';

  /// Retrieves or generates a persistent unique device ID
  static Future<String> getUniqueId() async {
    // Check if the ID already exists in secure storage
    String? uniqueId = await _storage.read(key: _key);
    if (uniqueId != null) {
      return uniqueId;
    }

    // Generate a new UUID
    uniqueId = const Uuid().v4();

    // Save the ID in secure storage
    await _storage.write(key: _key, value: uniqueId);
    return uniqueId;
  }
}
