import 'package:get_storage/get_storage.dart';

enum StoreKeys {
  /// SAF目录
  safDirectory,
}

class LocalStorage {
  static final LocalStorage _storage = LocalStorage._internal();
  final GetStorage _box = GetStorage();

  GetStorage get box => _box;

  LocalStorage._internal();

  factory LocalStorage() => _storage;

  Future<void> setSafDirectory(String safPath) {
    return _box.write(StoreKeys.safDirectory.name, safPath);
  }

  String? getSafDirectory() {
    return _box.read<String>(StoreKeys.safDirectory.name);
  }
}
