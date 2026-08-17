import 'package:flutter/material.dart';

/// Inherited scope that lets each page declare an action for the global FAB.
/// The shell reads [of] to wire the FAB.
class FabActionScope extends InheritedWidget {
  final VoidCallback onAdd;
  final IconData icon;
  final String label;
  const FabActionScope({
    super.key,
    required this.onAdd,
    required this.icon,
    required this.label,
    required super.child,
  });

  static FabActionScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FabActionScope>();
    assert(scope != null,
        'FabActionScope.of called from a context that does not wrap it');
    return scope!;
  }

  @override
  bool updateShouldNotify(FabActionScope old) =>
      onAdd != old.onAdd || icon != old.icon || label != old.label;
}
