import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/recipe.dart';
import '../controllers/recipe_controller.dart';
import '../dialogs/add_recipe_dialog.dart';
import '../widgets/fab_scope.dart';
import 'home_shell_page.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  Future<void> _add(BuildContext context, {String? day}) async {
    final days = context.read<RecipeController>().days;
    final result = await showAddRecipeDialog(
      context: context,
      existingDays: days,
      initialDay: day,
    );
    if (result == null || !context.mounted) return;
    await context.read<RecipeController>().add(
          day: result.day,
          meal: result.meal,
          name: result.name,
          ingredients: result.ingredients,
          preparation: result.preparation,
          origin: result.origin,
        );
  }

  Future<void> _confirmDelete(BuildContext context, Recipe r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar receta'),
        content: Text('¿Eliminar "${r.name}"?'),
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
    await context.read<RecipeController>().remove(r.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final controller = context.watch<RecipeController>();
    final days = controller.days;

    return FabActionScope(
      onAdd: () => _add(context, day: controller.filter),
      icon: Icons.add,
      label: 'Receta',
      child: PageScaffold(
        title: 'Recetas',
        subtitle: 'Recetario semanal',
        child: controller.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                    child: SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            label: 'Todas',
                            selected: controller.filter == null,
                            onTap: () => controller.setFilter(null),
                          ),
                          for (final d in days)
                            _FilterChip(
                              label: d,
                              selected: controller.filter == d,
                              onTap: () => controller.setFilter(d),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                      children: [
                        for (final d in days)
                          if (controller.filter == null || controller.filter == d)
                            _DayRecipes(
                              day: d,
                              recipes: controller.byDay[d]!,
                              onAdd: () => _add(context, day: d),
                              onDelete: (r) => _confirmDelete(context, r),
                            ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: t.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bolt_outlined,
                                  color: t.colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Las recetas respetan la grilla y los recetarios. Donde la grilla solo nombra la preparación, figura como "adaptación práctica".',
                                  style: t.textTheme.bodyMedium,
                                ),
                              ),
                            ],
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? t.colorScheme.primary
                : t.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            label,
            style: t.textTheme.labelSmall?.copyWith(
              color: selected ? t.colorScheme.onPrimary : t.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayRecipes extends StatelessWidget {
  final String day;
  final List<Recipe> recipes;
  final VoidCallback onAdd;
  final void Function(Recipe) onDelete;
  const _DayRecipes({
    required this.day,
    required this.recipes,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
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
                Text(day, style: t.textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  tooltip: 'Agregar receta a $day',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline),
                  color: t.colorScheme.primary,
                ),
              ],
            ),
          ),
          for (final r in recipes) _RecipeCard(recipe: r, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final void Function(Recipe) onDelete;
  const _RecipeCard({required this.recipe, required this.onDelete});

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onLongPress: () => widget.onDelete(widget.recipe),
        child: Card(
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.recipe.meal.toUpperCase(),
                              style: t.textTheme.labelSmall?.copyWith(
                                color: t.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.recipe.name,
                              style: t.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: t.colorScheme.outline,
                      ),
                    ],
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 14),
                    _Block(
                      icon: Icons.shopping_basket_outlined,
                      title: 'Ingredientes para 2',
                      body: widget.recipe.ingredients,
                    ),
                    const SizedBox(height: 12),
                    _Block(
                      icon: Icons.local_fire_department_outlined,
                      title: 'Preparación',
                      body: widget.recipe.preparation,
                    ),
                    if (widget.recipe.origin.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: t.colorScheme.secondaryContainer
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.recipe.origin,
                          style: t.textTheme.labelSmall?.copyWith(
                            color: t.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Block({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: t.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: t.textTheme.labelSmall?.copyWith(
                color: t.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(body, style: t.textTheme.bodyMedium),
      ],
    );
  }
}
