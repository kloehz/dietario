import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/supabase_client.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../data/repositories/prep_repository_impl.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../data/repositories/shopping_repository_impl.dart';
import '../../data/services/active_household_store.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/household_service.dart';
import '../../data/services/sync_coordinator.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/repositories/prep_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/shopping_repository.dart';

class AppLocator {
  AppLocator._();

  static AppLocator? _i;
  static AppLocator get instance => _i ??= AppLocator._();

  late final SharedPreferences prefs;
  late final ActiveHouseholdStore householdStore;
  late final AuthService auth;
  late final HouseholdService households;
  late final AppDatabase db;

  late final MenuRepositoryImpl menuRepo;
  late final ShoppingRepositoryImpl shoppingRepo;
  late final RecipeRepositoryImpl recipeRepo;
  late final PrepRepositoryImpl prepRepo;
  late final NotesRepositoryImpl notesRepo;

  late final SyncCoordinator sync;

  Future<void> bootstrap() async {
    await SupabaseBootstrap.initialize();
    prefs = await SharedPreferences.getInstance();
    householdStore = ActiveHouseholdStore(prefs);
    auth = AuthService();
    households = HouseholdService();
    db = AppDatabase.instance;
    // Touch the DB so the first read isn't blocked by migration.
    await db.database;

    menuRepo = MenuRepositoryImpl(db);
    shoppingRepo = ShoppingRepositoryImpl(db);
    recipeRepo = RecipeRepositoryImpl(db);
    prepRepo = PrepRepositoryImpl(db);
    notesRepo = NotesRepositoryImpl(db);

    sync = SyncCoordinator(
      menu: menuRepo,
      shopping: shoppingRepo,
      recipes: recipeRepo,
      prep: prepRepo,
      notes: notesRepo,
      households: households,
    );
  }

  // Abstract types for use by presentation (controllers). Repos expose
  // both the impl (for SyncCoordinator) and the interface.
  MenuRepository get menuInterface => menuRepo;
  ShoppingRepository get shoppingInterface => shoppingRepo;
  RecipeRepository get recipeInterface => recipeRepo;
  PrepRepository get prepInterface => prepRepo;
  NotesRepository get notesInterface => notesRepo;
}
