import 'package:flutter/foundation.dart';

import '../../data/services/household_service.dart';
import '../../data/services/sync_coordinator.dart';

class HouseholdController extends ChangeNotifier {
  final HouseholdService _service;
  final SyncCoordinator _sync;

  HouseholdController(this._service, this._sync);

  Household? _current;
  bool _loading = false;
  String? _error;

  Household? get current => _current;
  bool get loading => _loading;
  String? get error => _error;

  /// Loads the current household (if any) for the signed-in user and
  /// starts realtime sync.
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final h = await _service.current();
      _current = h;
      if (h != null) {
        await _sync.connect(h.id);
      } else {
        await _sync.disconnect();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Household> create({required String name}) async {
    final h = await _service.create(name: name);
    _current = h;
    await _sync.connect(h.id);
    notifyListeners();
    return h;
  }

  Future<Household> joinByCode({required String code}) async {
    final h = await _service.joinByCode(code: code);
    _current = h;
    await _sync.connect(h.id);
    notifyListeners();
    return h;
  }

  Future<void> signOut() async {
    await _sync.disconnect();
    _current = null;
    notifyListeners();
  }
}
