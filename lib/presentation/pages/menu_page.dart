import 'package:flutter/material.dart' hide MenuController;
import 'package:provider/provider.dart';

import '../../domain/entities/day_meal.dart';
import '../controllers/menu_controller.dart';
import '../dialogs/add_meal_dialog.dart';
import '../widgets/fab_scope.dart';
import '../widgets/section_header.dart';
import 'home_shell_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  static const _dayOrder = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  Future<void> _add(BuildContext context) async {
    final result = await showAddMealDialog(context: context);
    if (result == null || !context.mounted) return;
    await context.read<MenuController>().add(
          day: result.day,
          slot: result.slot,
          text: result.text,
          menuCode: result.menuCode,
          note: result.note,
        );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DayMeal meal,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar comida'),
        content: Text('¿Eliminar "${meal.text.length > 60 ? '${meal.text.substring(0, 60)}…' : meal.text}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<MenuController>().remove(meal.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final controller = context.watch<MenuController>();
    final byDay = controller.byDay;

    return FabActionScope(
      onAdd: () => _add(context),
      icon: Icons.add,
      label: 'Comida',
      child: PageScaffold(
        title: 'Plan semanal',
        subtitle: 'Menú para 2 personas',
        banner: const InfoBanner(
          icon: Icons.local_drink_outlined,
          text: '1 fruta cítrica por persona + 1 fruta extra. Agua como hidratación principal.',
        ),
        child: controller.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  for (final day in _dayOrder)
                    if (byDay[day] != null)
                      _DaySection(
                        day: day,
                        meals: byDay[day]!,
                        onDelete: (m) => _confirmDelete(context, m),
                      ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.eco_outlined, color: t.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Regla simple: separar mate/té/café al menos 1 hora de las comidas principales.',
                            style: t.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final String day;
  final List<DayMeal> meals;
  final void Function(DayMeal) onDelete;
  const _DaySection({
    required this.day,
    required this.meals,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final menuCode = meals.firstWhere(
      (m) => m.menuCode != null,
      orElse: () => meals.first,
    ).menuCode;

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 22,
                  decoration: BoxDecoration(
                    color: t.colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  day,
                  style: t.textTheme.titleMedium,
                ),
                const Spacer(),
                if (menuCode != null)
                  StatusChip(
                    label: menuCode,
                    color: t.colorScheme.primary,
                    icon: Icons.bookmark_outline,
                  ),
              ],
            ),
          ),
          for (final meal in meals) _MealCard(meal: meal, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final DayMeal meal;
  final void Function(DayMeal) onDelete;
  const _MealCard({required this.meal, required this.onDelete});

  IconData _icon(MealSlot s) {
    switch (s) {
      case MealSlot.desayuno:
        return Icons.wb_sunny_outlined;
      case MealSlot.almuerzo:
        return Icons.lunch_dining_outlined;
      case MealSlot.merienda:
        return Icons.coffee_outlined;
      case MealSlot.cena:
        return Icons.nightlight_outlined;
    }
  }

  Color _color(MealSlot s) {
    switch (s) {
      case MealSlot.desayuno:
        return const Color(0xFFE8A87C);
      case MealSlot.almuerzo:
        return const Color(0xFF3F7D58);
      case MealSlot.merienda:
        return const Color(0xFFC38D9E);
      case MealSlot.cena:
        return const Color(0xFF6C5B7B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final color = _color(meal.slot);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onLongPress: () => onDelete(meal),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon(meal.slot), color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            meal.slot.label.toUpperCase(),
                            style: t.textTheme.labelSmall?.copyWith(
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(meal.text, style: t.textTheme.bodyLarge),
                      if (meal.note != null && meal.note!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.sticky_note_2_outlined,
                                size: 14, color: t.colorScheme.outline),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                meal.note!,
                                style: t.textTheme.bodySmall?.copyWith(
                                  color: t.colorScheme.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
