import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/remote/remote_sync_source.dart';
import '../repositories/menu_repository_impl.dart';
import '../repositories/notes_repository_impl.dart';
import '../repositories/prep_repository_impl.dart';
import '../repositories/recipe_repository_impl.dart';
import '../repositories/shopping_repository_impl.dart';
import '../services/household_service.dart';

/// Wires a household to a remote sync source, performs the initial pull
/// into the local cache, and dispatches realtime events to the right repo.
///
/// Each step is wrapped in its own try/catch so a single failure (e.g.
/// realtime auth failing on web) doesn't take down the whole app — the
/// app still works, just without live sync.
class SyncCoordinator {
  final MenuRepositoryImpl menu;
  final ShoppingRepositoryImpl shopping;
  final RecipeRepositoryImpl recipes;
  final PrepRepositoryImpl prep;
  final NotesRepositoryImpl notes;
  final HouseholdService households;

  RealtimeChannel? _activeChannel;
  final _tickController = StreamController<void>.broadcast();

  Stream<void> get tick => _tickController.stream;

  SyncCoordinator({
    required this.menu,
    required this.shopping,
    required this.recipes,
    required this.prep,
    required this.notes,
    required this.households,
  });

  Future<void> dispose() async {
    await disconnect();
    await _tickController.close();
  }

  /// Connects to a household. Always returns; errors are logged but
  /// don't propagate. The household is set, the seed runs (best-effort),
  /// each table pulls (best-effort), and the realtime subscription
  /// attempts to attach — but any single failure is contained.
  Future<void> connect(String householdId) async {
    debugPrint('[sync] connect household=$householdId');
    await disconnect();

    final remote = RemoteSyncSource(householdId);
    menu.bindRemote(remote);
    shopping.bindRemote(remote);
    recipes.bindRemote(remote);
    prep.bindRemote(remote);
    notes.bindRemote(remote);

    await _seedIfEmpty(remote, householdId);

    await _safe('meals', () => menu.syncPull());
    await _safe('shopping', () => shopping.syncPull());
    await _safe('recipes', () => recipes.syncPull());
    await _safe('prep', () => prep.syncPull());
    await _safe('notes', () => notes.syncPull());

    await _subscribe(remote);
    _tickController.add(null); // initial pull finished
  }

  Future<void> disconnect() async {
    final channel = _activeChannel;
    _activeChannel = null;
    if (channel != null) {
      try {
        await Supabase.instance.client.removeChannel(channel);
      } catch (e) {
        debugPrint('[sync] disconnect: removeChannel failed: $e');
      }
    }
    menu.bindRemote(null);
    shopping.bindRemote(null);
    recipes.bindRemote(null);
    prep.bindRemote(null);
    notes.bindRemote(null);
  }

  Future<void> _seedIfEmpty(
    RemoteSyncSource remote,
    String householdId,
  ) async {
    try {
      final existing = await remote.fetchMeals();
      if (existing.isEmpty) {
        debugPrint('[sync] seeding default plan');
        await remote.seedDefaultPlan();
        debugPrint('[sync] seed done');
      }
    } catch (e, st) {
      debugPrint('[sync] seed failed: $e\n$st');
    }
  }

  Future<void> _safe(String label, Future<void> Function() op) async {
    try {
      await op();
    } catch (e, st) {
      debugPrint('[sync] pull $label failed: $e\n$st');
    }
  }

  Future<void> _subscribe(RemoteSyncSource remote) async {
    try {
      debugPrint('[sync] subscribing to realtime');
      final channel = remote.subscribeAll(onChange: _dispatch);
      _activeChannel = channel;
      debugPrint('[sync] realtime subscribed');
    } catch (e, st) {
      debugPrint('[sync] subscribe failed (app will keep working without realtime): $e\n$st');
      _activeChannel = null;
    }
  }

  void _dispatch(RemoteChange change) {
    try {
      switch (change.type) {
        case RemoteEntityType.meal:
          menu.applyRemoteChange(change);
          break;
        case RemoteEntityType.shopping:
          shopping.applyRemoteChange(change);
          break;
        case RemoteEntityType.recipe:
          recipes.applyRemoteChange(change);
          break;
        case RemoteEntityType.prep:
          prep.applyRemoteChange(change);
          break;
        case RemoteEntityType.note:
          notes.applyRemoteChange(change);
          break;
      }
      _tickController.add(null);
    } catch (e, st) {
      debugPrint('[sync] dispatch failed: $e\n$st');
    }
  }
}
