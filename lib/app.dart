import 'package:flutter/material.dart' hide MenuController;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/di/locator.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/menu_repository.dart';
import 'domain/repositories/notes_repository.dart';
import 'domain/repositories/prep_repository.dart';
import 'domain/repositories/recipe_repository.dart';
import 'domain/repositories/shopping_repository.dart';
import 'presentation/controllers/menu_controller.dart';
import 'presentation/controllers/notes_controller.dart';
import 'presentation/controllers/prep_controller.dart';
import 'presentation/controllers/recipe_controller.dart';
import 'presentation/controllers/shopping_controller.dart';
import 'presentation/pages/home_shell_page.dart';
import 'presentation/pages/menu_page.dart';
import 'presentation/pages/notes_page.dart';
import 'presentation/pages/prep_page.dart';
import 'presentation/pages/recipes_page.dart';
import 'presentation/pages/shopping_page.dart';

class DietarioApp extends StatefulWidget {
  const DietarioApp({super.key});

  @override
  State<DietarioApp> createState() => _DietarioAppState();
}

class _DietarioAppState extends State<DietarioApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/menu',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            final loc = state.matchedLocation;
            final idx = _indexFor(loc);
            return HomeShellPage(currentIndex: idx, child: child);
          },
          routes: [
            GoRoute(
              path: '/menu',
              pageBuilder: (_, _) =>
                  const NoTransitionPage(child: MenuPage()),
            ),
            GoRoute(
              path: '/shopping',
              pageBuilder: (_, _) =>
                  const NoTransitionPage(child: ShoppingPage()),
            ),
            GoRoute(
              path: '/recipes',
              pageBuilder: (_, _) =>
                  const NoTransitionPage(child: RecipesPage()),
            ),
            GoRoute(
              path: '/prep',
              pageBuilder: (_, _) =>
                  const NoTransitionPage(child: PrepPage()),
            ),
            GoRoute(
              path: '/notes',
              pageBuilder: (_, _) =>
                  const NoTransitionPage(child: NotesPage()),
            ),
          ],
        ),
      ],
    );
  }

  int _indexFor(String loc) {
    if (loc.startsWith('/shopping')) return 1;
    if (loc.startsWith('/recipes')) return 2;
    if (loc.startsWith('/prep')) return 3;
    if (loc.startsWith('/notes')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocator.instance;
    return MultiProvider(
      providers: [
        Provider<MenuRepository>.value(value: loc.menuRepo),
        Provider<ShoppingRepository>.value(value: loc.shoppingRepo),
        Provider<RecipeRepository>.value(value: loc.recipeRepo),
        Provider<PrepRepository>.value(value: loc.prepRepo),
        Provider<NotesRepository>.value(value: loc.notesRepo),
        ChangeNotifierProvider<MenuController>(
          create: (_) => MenuController(loc.menuRepo)..load(),
        ),
        ChangeNotifierProvider<ShoppingController>(
          create: (_) => ShoppingController(loc.shoppingRepo)..load(),
        ),
        ChangeNotifierProvider<RecipeController>(
          create: (_) => RecipeController(loc.recipeRepo)..load(),
        ),
        ChangeNotifierProvider<PrepController>(
          create: (_) => PrepController(loc.prepRepo)..load(),
        ),
        ChangeNotifierProvider<NotesController>(
          create: (_) => NotesController(loc.notesRepo)..load(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Dietario',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}
