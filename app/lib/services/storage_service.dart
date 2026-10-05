import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesStorage implements StorageService {
  static const key = 'civics_study.v1';
  final SharedPreferencesAsync preferences = SharedPreferencesAsync();
  @override
  Future<String?> read() => preferences.getString(key);
  @override
  Future<void> write(String value) => preferences.setString(key, value);
}
