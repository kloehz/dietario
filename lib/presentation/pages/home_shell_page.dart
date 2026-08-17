import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/fab_scope.dart';
import '../widgets/section_header.dart';

class HomeShellPage extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  const HomeShellPage({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  static const _items = [
    ('Menú', Icons.restaurant_menu_outlined, Icons.restaurant_menu, '/menu'),
    ('Compras', Icons.shopping_basket_outlined, Icons.shopping_basket, '/shopping'),
    ('Recetas', Icons.menu_book_outlined, Icons.menu_book, '/recipes'),
    ('Prep', Icons.kitchen_outlined, Icons.kitchen, '/prep'),
    ('Notas', Icons.notes_outlined, Icons.notes, '/notes'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final fab = FabActionScope.of(context);
    return Scaffold(
      body: SafeArea(bottom: false, child: child),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: fab.onAdd,
        icon: Icon(fab.icon),
        label: Text(fab.label),
        backgroundColor: t.colorScheme.primary,
        foregroundColor: t.colorScheme.onPrimary,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: t.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => context.go(_items[i].$4),
            backgroundColor: Colors.transparent,
            indicatorColor: t.colorScheme.primary.withValues(alpha: 0.18),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            height: 68,
            destinations: [
              for (final item in _items)
                NavigationDestination(
                  icon: Icon(item.$2),
                  selectedIcon: Icon(item.$3, color: t.colorScheme.primary),
                  label: item.$1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final Widget? banner;
  final Widget? progress;

  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions = const [],
    this.banner,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
          trailing: actions.isEmpty
              ? null
              : Row(mainAxisSize: MainAxisSize.min, children: actions),
        ),
        ?banner,
        ?progress,
        Expanded(child: child),
      ],
    );
  }
}
