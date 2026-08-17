import 'dart:async';

import 'package:flutter/material.dart' hide MenuController;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/di/locator.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/menu_repository_impl.dart';
import 'data/repositories/notes_repository_impl.dart';
import 'data/repositories/prep_repository_impl.dart';
import 'data/repositories/recipe_repository_impl.dart';
import 'data/repositories/shopping_repository_impl.dart';
import 'data/services/auth_service.dart';
import 'data/services/household_service.dart';
import 'domain/repositories/menu_repository.dart';
import 'domain/repositories/notes_repository.dart';
import 'domain/repositories/prep_repository.dart';
import 'domain/repositories/recipe_repository.dart';
import 'domain/repositories/shopping_repository.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/household_controller.dart';
import 'presentation/controllers/menu_controller.dart';
import 'presentation/controllers/notes_controller.dart';
import 'presentation/controllers/prep_controller.dart';
import 'presentation/controllers/recipe_controller.dart';
import 'presentation/controllers/shopping_controller.dart';
import 'presentation/pages/auth/household_setup_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/signup_page.dart';
import 'presentation/pages/home_shell_page.dart';
import 'presentation/pages/menu_page.dart';
import 'presentation/pages/notes_page.dart';
import 'presentation/pages/prep_page.dart';
import 'presentation/pages/recipes_page.dart';
import 'presentation/pages/shopping_page.dart';
import 'presentation/widgets/fab_scope.dart';

class DietarioApp extends StatefulWidget {
  const DietarioApp({super.key});

  @override
  State<DietarioApp> createState() => _DietarioAppState();
}

class _DietarioAppState extends State<DietarioApp> {
  late final GoRouter _router;
  late final AuthController _auth;
  late final HouseholdController _household;

  @override
  void initState() {
    super.initState();
    _auth = AuthController(AppLocator.instance.auth);
    _household =
        HouseholdController(AppLocator.instance.households, AppLocator.instance.sync);
    _router = _buildRouter();
    // Bootstrap: load household once auth becomes available.
    _auth.addListener(_onAuthChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _household.load();
    });
  }

  void _onAuthChanged() {
    if (_auth.status == AuthStatus.signedIn) {
      _household.load();
    } else {
      _household.signOut();
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _auth.dispose();
    _household.dispose();
    super.dispose();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: _auth,
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final loggedIn = _auth.status == AuthStatus.signedIn;

        if (_auth.status == AuthStatus.unknown) return null;

        if (!loggedIn &&
            loc != '/login' &&
            loc != '/signup') {
          return '/login';
        }
        if (loggedIn && (loc == '/login' || loc == '/signup')) {
          if (_household.current != null) return '/menu';
          if (_household.loading) return null;
          return '/household';
        }
        if (loggedIn && loc == '/household' && _household.current != null) {
          return '/menu';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, _) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (_, _) => const SignupPage(),
        ),
        GoRoute(
          path: '/household',
          builder: (_, _) => const HouseholdSetupPage(),
        ),
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
        Provider<AuthService>.value(value: loc.auth),
        Provider<HouseholdService>.value(value: loc.households),
        Provider<MenuRepository>.value(value: loc.menuInterface),
        Provider<ShoppingRepository>.value(value: loc.shoppingInterface),
        Provider<RecipeRepository>.value(value: loc.recipeInterface),
        Provider<PrepRepository>.value(value: loc.prepInterface),
        Provider<NotesRepository>.value(value: loc.notesInterface),
        ChangeNotifierProvider<AuthController>.value(value: _auth),
        ChangeNotifierProvider<HouseholdController>.value(value: _household),
        ChangeNotifierProvider<MenuController>(
          create: (_) =>
              MenuController(loc.menuInterface as MenuRepositoryImpl)..load(),
        ),
        ChangeNotifierProvider<ShoppingController>(
          create: (_) => ShoppingController(
            loc.shoppingInterface as ShoppingRepositoryImpl,
          )..load(),
        ),
        ChangeNotifierProvider<RecipeController>(
          create: (_) => RecipeController(
            loc.recipeInterface as RecipeRepositoryImpl,
          )..load(),
        ),
        ChangeNotifierProvider<PrepController>(
          create: (_) => PrepController(
            loc.prepInterface as PrepRepositoryImpl,
          )..load(),
        ),
        ChangeNotifierProvider<NotesController>(
          create: (_) => NotesController(
            loc.notesInterface as NotesRepositoryImpl,
          )..load(),
        ),
        ChangeNotifierProvider(create: (_) => FabController()),
      ],
      child: _WireSync(
        child: MaterialApp.router(
          title: 'Dietario',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          routerConfig: _router,
        ),
      ),
    );
  }
}

/// Hooks every domain controller to the sync coordinator's tick stream so
/// that a remote change (from the partner) reloads the local in-memory
/// state and the UI updates automatically.
class _WireSync extends StatefulWidget {
  final Widget child;
  const _WireSync({required this.child});

  @override
  State<_WireSync> createState() => _WireSyncState();
}

class _WireSyncState extends State<_WireSync> {
  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
    final coord = AppLocator.instance.sync;
    _sub = coord.tick.listen((_) {
      if (!mounted) return;
      context.read<MenuController>().load();
      context.read<ShoppingController>().load();
      context.read<RecipeController>().load();
      context.read<PrepController>().load();
      context.read<NotesController>().load();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
