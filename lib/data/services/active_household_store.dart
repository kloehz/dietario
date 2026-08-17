import 'package:shared_preferences/shared_preferences.dart';

class ActiveHouseholdStore {
  static const _key = 'active_household_id';

  final SharedPreferences _prefs;
  ActiveHouseholdStore(this._prefs);

  String? get activeId => _prefs.getString(_key);

  Future<void> set(String id) async {
    await _prefs.setString(_key, id);
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
