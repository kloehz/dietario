import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/remote/supabase_client.dart';

class Household {
  final String id;
  final String name;
  final String inviteCode;

  const Household({
    required this.id,
    required this.name,
    required this.inviteCode,
  });

  factory Household.fromRow(Map<String, dynamic> row) => Household(
        id: row['id'] as String,
        name: row['name'] as String? ?? 'Nuestro hogar',
        inviteCode: row['invite_code'] as String,
      );
}

class HouseholdService {
  SupabaseClient get _client => SupabaseBootstrap.client;

  /// Creates a household, generates an invite code, and adds the current
  /// user as its first member.
  Future<Household> create({required String name}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not authenticated');

    final inviteCode = _generateInviteCode();
    final inserted = await _client
        .from('households')
        .insert({'name': name, 'invite_code': inviteCode})
        .select()
        .single();

    await _client.from('household_members').insert({
      'household_id': inserted['id'],
      'user_id': userId,
    });

    return Household.fromRow(inserted);
  }

  /// Looks up a household by its 6-char invite code and joins it.
  /// Throws if the code is invalid.
  Future<Household> joinByCode({required String code}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not authenticated');

    final normalized = code.trim().toUpperCase();
    final rows = await _client
        .from('households')
        .select()
        .eq('invite_code', normalized)
        .limit(1);

    if (rows.isEmpty) {
      throw const FormatException('Código de invitación inválido');
    }

    final row = rows.first;

    await _client.from('household_members').insert({
      'household_id': row['id'],
      'user_id': userId,
    });

    return Household.fromRow(row);
  }

  /// Returns the household(s) the current user belongs to. We expect 0 or 1
  /// in normal usage; multiple means the user is in several — we pick the
  /// most recently joined.
  Future<Household?> current() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final rows = await _client
        .from('household_members')
        .select('household_id, joined_at, households(*)')
        .eq('user_id', userId)
        .order('joined_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    final row = rows.first;
    final household = row['households'];
    if (household == null) return null;
    return Household.fromRow(Map<String, dynamic>.from(household as Map));
  }

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
