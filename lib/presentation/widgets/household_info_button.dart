import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/household_controller.dart';

/// Small icon button that opens a bottom sheet with the current household
/// invite code (so the user can copy and share it with their partner)
/// and a sign-out action.
class HouseholdInfoButton extends StatelessWidget {
  const HouseholdInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    final household = context.watch<HouseholdController>().current;
    if (household == null) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.group_outlined),
      tooltip: 'Hogar e invitación',
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _HouseholdSheet(),
      ),
    );
  }
}

class _HouseholdSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final household = context.watch<HouseholdController>().current;
    if (household == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.home_outlined, color: t.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(household.name,
                      style: t.textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Compartí este código con tu pareja para que se una al mismo hogar y vean los cambios en tiempo real.',
              style: t.textTheme.bodySmall
                  ?.copyWith(color: t.colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: t.colorScheme.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      household.inviteCode,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        color: t.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: household.inviteCode),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código copiado')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copiar',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<HouseholdController>().signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
