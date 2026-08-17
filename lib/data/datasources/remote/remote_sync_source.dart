import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/day_meal.dart';
import '../../../domain/entities/plan_note.dart';
import '../../../domain/entities/prep_task.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/entities/shopping_item.dart';
import 'remote_mappers.dart';
import 'supabase_client.dart';

/// Centralizes Supabase CRUD + realtime for all five domain entities,
/// scoped to the active household. Each method returns `void` on success;
/// callers only need the remote_id back from inserts.
class RemoteSyncSource {
  SupabaseClient get _c => SupabaseBootstrap.client;
  final String householdId;

  RemoteSyncSource(this.householdId);

  // ---------- Read all (used on initial pull) ----------
  Future<List<DayMeal>> fetchMeals() async {
    final rows = await _c
        .from('day_meals')
        .select()
        .eq('household_id', householdId)
        .order('order_index');
    return rows.map((r) => RemoteMappers.meal(r)).toList();
  }

  Future<List<ShoppingItem>> fetchShopping() async {
    final rows = await _c
        .from('shopping_items')
        .select()
        .eq('household_id', householdId)
        .order('order_index');
    return rows.map((r) => RemoteMappers.shopping(r)).toList();
  }

  Future<List<Recipe>> fetchRecipes() async {
    final rows = await _c
        .from('recipes')
        .select()
        .eq('household_id', householdId)
        .order('order_index');
    return rows.map((r) => RemoteMappers.recipe(r)).toList();
  }

  Future<List<PrepTask>> fetchPrep() async {
    final rows = await _c
        .from('prep_tasks')
        .select()
        .eq('household_id', householdId)
        .order('order_index');
    return rows.map((r) => RemoteMappers.prep(r)).toList();
  }

  Future<List<PlanNote>> fetchNotes() async {
    final rows = await _c
        .from('plan_notes')
        .select()
        .eq('household_id', householdId)
        .order('order_index');
    return rows.map((r) => RemoteMappers.note(r)).toList();
  }

  // ---------- Inserts ----------
  Future<String> insertMeal(DayMeal m) async {
    final id = await _c
        .from('day_meals')
        .insert(RemotePayloads.mealRow(
          remoteId: '',
          householdId: householdId,
          m: m,
        ))
        .select('id')
        .single();
    return id['id'] as String;
  }

  Future<String> insertShopping(ShoppingItem i) async {
    final id = await _c
        .from('shopping_items')
        .insert(RemotePayloads.shoppingRow(
          remoteId: '',
          householdId: householdId,
          i: i,
        ))
        .select('id')
        .single();
    return id['id'] as String;
  }

  Future<String> insertRecipe(Recipe r) async {
    final id = await _c
        .from('recipes')
        .insert(RemotePayloads.recipeRow(
          remoteId: '',
          householdId: householdId,
          r: r,
        ))
        .select('id')
        .single();
    return id['id'] as String;
  }

  Future<String> insertPrep(PrepTask t) async {
    final id = await _c
        .from('prep_tasks')
        .insert(RemotePayloads.prepRow(
          remoteId: '',
          householdId: householdId,
          t: t,
        ))
        .select('id')
        .single();
    return id['id'] as String;
  }

  Future<String> insertNote(PlanNote n) async {
    final id = await _c
        .from('plan_notes')
        .insert(RemotePayloads.noteRow(
          remoteId: '',
          householdId: householdId,
          n: n,
        ))
        .select('id')
        .single();
    return id['id'] as String;
  }

  // ---------- Updates ----------
  Future<void> updateMeal(String remoteId, DayMeal m) async {
    await _c.from('day_meals').update({
      'text': m.text,
      'menu_code': m.menuCode,
      'note': m.note,
      'order_index': m.orderIndex,
    }).eq('id', remoteId);
  }

  Future<void> updateShopping(String remoteId, ShoppingItem i) async {
    await _c.from('shopping_items').update({
      'category': i.category,
      'product': i.product,
      'quantity': i.quantity,
      'unit': i.unit,
      'notes': i.notes,
      'status': i.status.name,
      'order_index': i.orderIndex,
    }).eq('id', remoteId);
  }

  Future<void> updateRecipe(String remoteId, Recipe r) async {
    await _c.from('recipes').update({
      'name': r.name,
      'ingredients': r.ingredients,
      'preparation': r.preparation,
      'origin': r.origin,
      'order_index': r.orderIndex,
    }).eq('id', remoteId);
  }

  Future<void> updatePrep(String remoteId, PrepTask t) async {
    await _c.from('prep_tasks').update({
      'order_index': t.order,
      'task': t.task,
      'quantity': t.quantity,
      'purpose': t.purpose,
      'storage': t.storage,
      'status': t.status.name,
    }).eq('id', remoteId);
  }

  Future<void> updateNote(String remoteId, PlanNote n) async {
    await _c.from('plan_notes').update({
      'topic': n.topic,
      'respected': n.respected,
      'applied': n.applied,
      'source': n.source,
      'order_index': n.orderIndex,
    }).eq('id', remoteId);
  }

  // ---------- Deletes ----------
  Future<void> deleteMeal(String remoteId) =>
      _c.from('day_meals').delete().eq('id', remoteId);
  Future<void> deleteShopping(String remoteId) =>
      _c.from('shopping_items').delete().eq('id', remoteId);
  Future<void> deleteRecipe(String remoteId) =>
      _c.from('recipes').delete().eq('id', remoteId);
  Future<void> deletePrep(String remoteId) =>
      _c.from('prep_tasks').delete().eq('id', remoteId);
  Future<void> deleteNote(String remoteId) =>
      _c.from('plan_notes').delete().eq('id', remoteId);

  // ---------- Realtime subscription ----------
  /// Subscribes to INSERT/UPDATE/DELETE on all five tables for the active
  /// household. Returns a single stream with typed events and a single
  /// cancel callback.
  RealtimeChannel subscribeAll({
    required void Function(RemoteChange change) onChange,
  }) {
    final channel = _c.channel('household:$householdId');

    void wire(String table, RemoteEntityType type) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'household_id',
          value: householdId,
        ),
        callback: (event) {
          final id = (event.newRecord['id'] ?? event.oldRecord['id']) as String?;
          if (id == null) return;
          onChange(RemoteChange(
            type: type,
            event: event.eventType,
            remoteId: id,
            newRow: event.newRecord.isNotEmpty ? event.newRecord : null,
            oldRow: event.oldRecord.isNotEmpty ? event.oldRecord : null,
          ));
        },
      );
    }

    wire('day_meals', RemoteEntityType.meal);
    wire('shopping_items', RemoteEntityType.shopping);
    wire('recipes', RemoteEntityType.recipe);
    wire('prep_tasks', RemoteEntityType.prep);
    wire('plan_notes', RemoteEntityType.note);

    channel.subscribe();
    return channel;
  }

  /// Seeds a freshly created household with the default weekly plan from
  /// the Excel file. Called when a user creates a household for the first
  /// time so both partners see the same starting point.
  Future<void> seedDefaultPlan() async {
    final batch = <Future<dynamic>>[];

    for (final row in _defaultMeals()) {
      batch.add(_c.from('day_meals').insert({
        'household_id': householdId,
        ...row,
      }));
    }
    for (final row in _defaultShopping()) {
      batch.add(_c.from('shopping_items').insert({
        'household_id': householdId,
        ...row,
      }));
    }
    for (final row in _defaultRecipes()) {
      batch.add(_c.from('recipes').insert({
        'household_id': householdId,
        ...row,
      }));
    }
    for (final row in _defaultPrep()) {
      batch.add(_c.from('prep_tasks').insert({
        'household_id': householdId,
        ...row,
      }));
    }
    for (final row in _defaultNotes()) {
      batch.add(_c.from('plan_notes').insert({
        'household_id': householdId,
        ...row,
      }));
    }
    await Future.wait(batch);
  }

  // ---- Default plan seeds (subset of the original Excel) ----
  List<Map<String, dynamic>> _defaultMeals() => [
        {
          'day': 'Lunes',
          'slot': 'desayuno',
          'text':
              'Yogur natural + quinoa pop + manzana. + 1 cítrico por persona.',
          'menu_code': 'MENÚ 1',
          'note': null,
          'order_index': 0,
        },
        {
          'day': 'Lunes',
          'slot': 'almuerzo',
          'text':
              'Omelette de 2 huevos por persona relleno de espinaca + queso magro + ensalada de repollo, lentejas y zanahoria + semillas.',
          'menu_code': 'MENÚ 1',
          'note': null,
          'order_index': 1,
        },
        {
          'day': 'Miércoles',
          'slot': 'almuerzo',
          'text':
              'Filet de merluza + ensalada de remolacha, papa y huevo + semillas.',
          'menu_code': 'MENÚ 3',
          'note': null,
          'order_index': 8,
        },
        {
          'day': 'Viernes',
          'slot': 'cena',
          'text':
              'Tarta de atún y cebolla (1 sola tapa con semillas) + ensalada de zanahoria y repollo.',
          'menu_code': 'MENÚ 5',
          'note': null,
          'order_index': 19,
        },
        {
          'day': 'Domingo',
          'slot': 'almuerzo',
          'text':
              'Fideos de zucchini con salsa verde de acelga/espinaca y salsa blanca liviana. Queso rallado opcional.',
          'menu_code': 'MENÚ 7',
          'note': null,
          'order_index': 25,
        },
      ];

  List<Map<String, dynamic>> _defaultShopping() => [
        {
          'category': 'Verdulería',
          'product': 'Zanahoria',
          'quantity': 2.0,
          'unit': 'kg',
          'notes': 'Ensaladas, croquetas, medallones y verduras al horno',
          'status': 'pendiente',
          'order_index': 0,
        },
        {
          'category': 'Verdulería',
          'product': 'Limón',
          'quantity': 10.0,
          'unit': 'unidades',
          'notes': 'Pescado, pollo, ensaladas y hummus',
          'status': 'pendiente',
          'order_index': 15,
        },
        {
          'category': 'Frutas',
          'product': 'Manzana',
          'quantity': 6.0,
          'unit': 'unidades',
          'notes': 'Desayunos/meriendas',
          'status': 'pendiente',
          'order_index': 19,
        },
        {
          'category': 'Proteínas',
          'product': 'Huevos',
          'quantity': 30.0,
          'unit': 'unidades',
          'notes': 'Omelettes, ensaladas, rebozados y desayunos',
          'status': 'pendiente',
          'order_index': 22,
        },
      ];

  List<Map<String, dynamic>> _defaultRecipes() => [
        {
          'day': 'Lunes',
          'meal': 'Almuerzo',
          'name': 'Omelette de espinaca + ensalada de repollo y lentejas',
          'ingredients':
              '4 huevos; 200 g espinaca; 80 g queso magro; 250 g repollo; 2 zanahorias; 120 g lentejas cocidas; 2 cditas semillas; limón/oliva.',
          'preparation':
              '1) Saltear la espinaca. 2) Batir 2 huevos por persona; rellenar con espinaca y queso. 3) Mezclar repollo, zanahoria y lentejas. 4) Terminar con semillas y limón.',
          'origin': 'Grilla · MENÚ 1',
          'order_index': 0,
        },
      ];

  List<Map<String, dynamic>> _defaultPrep() => [
        {
          'order_index': 1,
          'task': 'Cocinar lentejas',
          'quantity': '350 g secas',
          'purpose': 'Medallones, albóndigas y ensalada del lunes',
          'storage': 'Porcionar en 1/2 taza y freezar',
          'status': 'pendiente',
        },
      ];

  List<Map<String, dynamic>> _defaultNotes() => [
        {
          'topic': 'Frutas y verduras',
          'respected':
              'Aumentar frutas/verduras; al menos 2 frutas y 2 verduras de base, con 1 cítrica diaria.',
          'applied': '14 cítricos y fruta extra para 2 personas.',
          'source': 'PLAN ALIMENTARIO',
          'order_index': 0,
        },
      ];
}

enum RemoteEntityType { meal, shopping, recipe, prep, note }

class RemoteChange {
  final RemoteEntityType type;
  final PostgresChangeEvent event;
  final String remoteId;
  final Map<String, dynamic>? newRow;
  final Map<String, dynamic>? oldRow;

  const RemoteChange({
    required this.type,
    required this.event,
    required this.remoteId,
    this.newRow,
    this.oldRow,
  });
}
