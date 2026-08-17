import 'dart:async';

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
/// Exposes [tick] — a stream that fires after every local write triggered
/// by a remote change (or by the initial pull). UI controllers can listen
/// to this stream to reload their in-memory state.
class SyncCoordinator {
  final MenuRepositoryImpl menu;
  final ShoppingRepositoryImpl shopping;
  final RecipeRepositoryImpl recipes;
  final PrepRepositoryImpl prep;
  final NotesRepositoryImpl notes;
  final HouseholdService households;

  RealtimeChannel? _activeChannel;
  final _tickController = StreamController<void>.broadcast();

  /// Fires once per remote change and once after the initial pull. Use it
  /// to invalidate cached state in controllers.
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

  /// Connects to a household, seeds if empty, pulls remote → local, and
  /// subscribes to realtime changes.
  Future<void> connect(String householdId) async {
    await disconnect();

    final remote = RemoteSyncSource(householdId);
    menu.bindRemote(remote);
    shopping.bindRemote(remote);
    recipes.bindRemote(remote);
    prep.bindRemote(remote);
    notes.bindRemote(remote);

    await _seedIfEmpty(remote, householdId);

    await Future.wait([
      menu.syncPull(),
      shopping.syncPull(),
      recipes.syncPull(),
      prep.syncPull(),
      notes.syncPull(),
    ]);

    _activeChannel = remote.subscribeAll(onChange: _dispatch);
    _tickController.add(null); // initial pull finished
  }

  Future<void> disconnect() async {
    if (_activeChannel != null) {
      await Supabase.instance.client.removeChannel(_activeChannel!);
      _activeChannel = null;
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
        await remote.seedDefaultPlan();
      }
    } catch (_) {
      // Best-effort seed.
    }
  }

  void _dispatch(RemoteChange change) {
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
  }
}
