import 'package:provider/provider.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../data/repositories/prep_repository_impl.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../data/repositories/shopping_repository_impl.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/repositories/prep_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/shopping_repository.dart';

class AppLocator {
  AppLocator._();

  static AppLocator? _i;
  static AppLocator get instance => _i ??= AppLocator._();

  late final AppDatabase db;
  late final MenuRepository menuRepo;
  late final ShoppingRepository shoppingRepo;
  late final RecipeRepository recipeRepo;
  late final PrepRepository prepRepo;
  late final NotesRepository notesRepo;

  Future<void> bootstrap() async {
    db = AppDatabase.instance;
    menuRepo = MenuRepositoryImpl(db);
    shoppingRepo = ShoppingRepositoryImpl(db);
    recipeRepo = RecipeRepositoryImpl(db);
    prepRepo = PrepRepositoryImpl(db);
    notesRepo = NotesRepositoryImpl(db);
    // Touch the DB so first read doesn't block UI.
    await db.database;
  }
}

Provider<T> repoProvider<T>(T Function() create) =>
    Provider<T>(create: (_) => create());
