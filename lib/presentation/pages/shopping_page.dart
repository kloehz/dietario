import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/shopping_item.dart';
import '../controllers/shopping_controller.dart';
import '../dialogs/add_shopping_dialog.dart';
import '../widgets/fab_scope.dart';
import '../widgets/section_header.dart';
import 'home_shell_page.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  Future<void> _add(BuildContext context, {String? category}) async {
    final cats = context.read<ShoppingController>().categories;
    final result = await showAddShoppingDialog(
      context: context,
      existingCategories: cats,
      initialCategory: category,
    );
    if (result == null || !context.mounted) return;
    await context.read<ShoppingController>().add(
          category: result.category,
          product: result.product,
          quantity: result.quantity,
          unit: result.unit,
          notes: result.notes,
        );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ShoppingItem item,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${item.product}"?'),
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
    await context.read<ShoppingController>().remove(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final controller = context.watch<ShoppingController>();

    return FabActionScope(
      onAdd: () => _add(context),
      icon: Icons.add_shopping_cart,
      label: 'Producto',
      child: PageScaffold(
        title: 'Lista de compras',
        subtitle: '2 personas · 7 días',
        progress: controller.total == 0
            ? null
            : ProgressBar(
                progress: controller.progress,
                label: 'Progreso de compra',
                detail: '${controller.purchased}/${controller.total}',
              ),
        child: controller.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                children: [
                  for (final cat in controller.categories)
                    _CategorySection(
                      category: cat,
                      items: controller.byCategory[cat]!,
                      onAddInCategory: () => _add(context, category: cat),
                      onDelete: (i) => _confirmDelete(context, i),
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
                        Icon(Icons.info_outline,
                            color: t.colorScheme.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Las cantidades son una estimación práctica. Condimentos, aceite y despensa pueden sobrar para semanas siguientes.',
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

class _CategorySection extends StatelessWidget {
  final String category;
  final List<ShoppingItem> items;
  final VoidCallback onAddInCategory;
  final void Function(ShoppingItem) onDelete;
  const _CategorySection({
    required this.category,
    required this.items,
    required this.onAddInCategory,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final pending =
        items.where((i) => i.status == ShoppingStatus.pendiente).length;

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
                Text(category, style: t.textTheme.titleMedium),
                const Spacer(),
                Text(
                  '$pending pendientes',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: t.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Agregar a $category',
                  onPressed: onAddInCategory,
                  icon: const Icon(Icons.add_circle_outline),
                  color: t.colorScheme.primary,
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _ShoppingTile(item: items[i], onDelete: onDelete),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color:
                          t.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingTile extends StatelessWidget {
  final ShoppingItem item;
  final void Function(ShoppingItem) onDelete;
  const _ShoppingTile({required this.item, required this.onDelete});

  String _qtyLabel() {
    final q = item.quantity;
    final qtyStr = q == q.roundToDouble()
        ? q.toInt().toString()
        : q.toStringAsFixed(q < 10 ? 1 : 0);
    return '$qtyStr ${item.unit}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isPurchased = item.status == ShoppingStatus.comprado;
    final controller = context.read<ShoppingController>();

    return GestureDetector(
      onLongPress: () => onDelete(item),
      child: InkWell(
        onTap: () => controller.toggleStatus(item),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isPurchased
                      ? t.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: isPurchased
                        ? t.colorScheme.primary
                        : t.colorScheme.outline.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: isPurchased
                    ? Icon(Icons.check, size: 14, color: t.colorScheme.onPrimary)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.product,
                            style: t.textTheme.titleSmall?.copyWith(
                              decoration: isPurchased
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isPurchased
                                  ? t.colorScheme.outline
                                  : t.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: t.colorScheme.primaryContainer
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            _qtyLabel(),
                            style: t.textTheme.labelSmall?.copyWith(
                              color: t.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.notes,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: t.colorScheme.outline,
                          decoration: isPurchased
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
