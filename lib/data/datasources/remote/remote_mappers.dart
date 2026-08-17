import '../../../domain/entities/day_meal.dart';
import '../../../domain/entities/plan_note.dart';
import '../../../domain/entities/prep_task.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/entities/shopping_item.dart';

/// Mappers from Supabase rows (snake_case) to domain entities (camelCase).
/// All mappers require a `household_id` because every remote row is scoped
/// to a household — this guards against forgetting the FK.
class RemoteMappers {
  static DayMeal meal(Map<String, dynamic> row) => DayMeal(
        id: 0,
        day: row['day'] as String,
        slot: _slot(row['slot'] as String),
        text: row['text'] as String,
        menuCode: row['menu_code'] as String?,
        note: row['note'] as String?,
        orderIndex: row['order_index'] as int,
        remoteId: row['id'] as String,
      );

  static ShoppingItem shopping(Map<String, dynamic> row) => ShoppingItem(
        id: 0,
        category: row['category'] as String,
        product: row['product'] as String,
        quantity: (row['quantity'] as num).toDouble(),
        unit: row['unit'] as String,
        notes: row['notes'] as String,
        status: _shoppingStatus(row['status'] as String),
        orderIndex: row['order_index'] as int,
        remoteId: row['id'] as String,
      );

  static Recipe recipe(Map<String, dynamic> row) => Recipe(
        id: 0,
        day: row['day'] as String,
        meal: row['meal'] as String,
        name: row['name'] as String,
        ingredients: row['ingredients'] as String,
        preparation: row['preparation'] as String,
        origin: row['origin'] as String,
        orderIndex: row['order_index'] as int,
        remoteId: row['id'] as String,
      );

  static PrepTask prep(Map<String, dynamic> row) => PrepTask(
        id: 0,
        order: row['order_index'] as int,
        task: row['task'] as String,
        quantity: row['quantity'] as String,
        purpose: row['purpose'] as String,
        storage: row['storage'] as String,
        status: _prepStatus(row['status'] as String),
        remoteId: row['id'] as String,
      );

  static PlanNote note(Map<String, dynamic> row) => PlanNote(
        id: 0,
        topic: row['topic'] as String,
        respected: row['respected'] as String,
        applied: row['applied'] as String,
        source: row['source'] as String,
        orderIndex: row['order_index'] as int,
        remoteId: row['id'] as String,
      );

  static MealSlot _slot(String s) => MealSlotX.fromKey(s);
  static ShoppingStatus _shoppingStatus(String s) => ShoppingStatusX.fromKey(s);
  static PrepStatus _prepStatus(String s) => PrepStatusX.fromKey(s);
}

class RemotePayloads {
  static Map<String, dynamic> mealRow({
    required String householdId,
    required DayMeal m,
  }) =>
      {
        'household_id': householdId,
        'day': m.day,
        'slot': m.slot.name,
        'text': m.text,
        'menu_code': m.menuCode,
        'note': m.note,
        'order_index': m.orderIndex,
      };

  static Map<String, dynamic> shoppingRow({
    required String householdId,
    required ShoppingItem i,
  }) =>
      {
        'household_id': householdId,
        'category': i.category,
        'product': i.product,
        'quantity': i.quantity,
        'unit': i.unit,
        'notes': i.notes,
        'status': i.status.name,
        'order_index': i.orderIndex,
      };

  static Map<String, dynamic> recipeRow({
    required String householdId,
    required Recipe r,
  }) =>
      {
        'household_id': householdId,
        'day': r.day,
        'meal': r.meal,
        'name': r.name,
        'ingredients': r.ingredients,
        'preparation': r.preparation,
        'origin': r.origin,
        'order_index': r.orderIndex,
      };

  static Map<String, dynamic> prepRow({
    required String householdId,
    required PrepTask t,
  }) =>
      {
        'household_id': householdId,
        'order_index': t.order,
        'task': t.task,
        'quantity': t.quantity,
        'purpose': t.purpose,
        'storage': t.storage,
        'status': t.status.name,
      };

  static Map<String, dynamic> noteRow({
    required String householdId,
    required PlanNote n,
  }) =>
      {
        'household_id': householdId,
        'topic': n.topic,
        'respected': n.respected,
        'applied': n.applied,
        'source': n.source,
        'order_index': n.orderIndex,
      };
}
