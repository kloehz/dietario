import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FabAction {
  final VoidCallback onAdd;
  final IconData icon;
  final String label;

  const FabAction({
    required this.onAdd,
    required this.icon,
    required this.label,
  });
}

class FabController extends ChangeNotifier {
  FabAction? _action;

  FabAction? get action => _action;

  void setAction(FabAction action) {
    _action = action;
    notifyListeners();
  }
}

/// Registers a page-specific action for the shell's global FAB.
class FabActionScope extends StatefulWidget {
  final VoidCallback onAdd;
  final IconData icon;
  final String label;
  final Widget child;

  const FabActionScope({
    super.key,
    required this.onAdd,
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  State<FabActionScope> createState() => _FabActionScopeState();
}

class _FabActionScopeState extends State<FabActionScope> {
  late FabAction _action;
  FabController? _controller;

  @override
  void initState() {
    super.initState();
    _action = _buildAction();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = context.read<FabController>();
    _scheduleRegistration();
  }

  @override
  void didUpdateWidget(covariant FabActionScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onAdd != widget.onAdd ||
        oldWidget.icon != widget.icon ||
        oldWidget.label != widget.label) {
      _action = _buildAction();
      _scheduleRegistration();
    }
  }

  void _scheduleRegistration() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller?.setAction(_action);
    });
  }

  FabAction _buildAction() => FabAction(
        onAdd: widget.onAdd,
        icon: widget.icon,
        label: widget.label,
      );

  @override
  Widget build(BuildContext context) => widget.child;
}
