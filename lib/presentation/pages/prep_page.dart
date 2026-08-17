import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/prep_task.dart';
import '../controllers/prep_controller.dart';
import '../dialogs/add_prep_dialog.dart';
import '../widgets/fab_scope.dart';
import '../widgets/section_header.dart';
import 'home_shell_page.dart';

class PrepPage extends StatelessWidget {
  const PrepPage({super.key});

  Future<void> _add(BuildContext context) async {
    final result = await showAddPrepDialog(context: context);
    if (result == null || !context.mounted) return;
    await context.read<PrepController>().add(
          order: 0,
          task: result.task,
          quantity: result.quantity,
          purpose: result.purpose,
          storage: result.storage,
        );
  }

  Future<void> _confirmDelete(BuildContext context, PrepTask task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${task.task}"?'),
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
    await context.read<PrepController>().remove(task.id);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrepController>();

    return FabActionScope(
      onAdd: () => _add(context),
      icon: Icons.add_task,
      label: 'Tarea',
      child: PageScaffold(
        title: 'Preparación semanal',
        subtitle: '60–90 min · una sola sesión',
        banner: const InfoBanner(
          icon: Icons.timer_outlined,
          text: 'Dejá bases listas para que durante la semana solo combines, calientes o cocines la proteína.',
        ),
        progress: controller.total == 0
            ? null
            : ProgressBar(
                progress: controller.progress,
                label: 'Progreso',
                detail: '${controller.done}/${controller.total}',
              ),
        child: controller.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                itemCount: controller.tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _PrepCard(
                  task: controller.tasks[i],
                  onDelete: () => _confirmDelete(context, controller.tasks[i]),
                ),
              ),
      ),
    );
  }
}

class _PrepCard extends StatelessWidget {
  final PrepTask task;
  final VoidCallback onDelete;
  const _PrepCard({required this.task, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDone = task.status == PrepStatus.hecho;
    final controller = context.read<PrepController>();

    return GestureDetector(
      onLongPress: onDelete,
      child: Card(
        child: InkWell(
          onTap: () => controller.toggleStatus(task),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDone
                        ? t.colorScheme.primary
                        : t.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${task.order}',
                    style: t.textTheme.titleSmall?.copyWith(
                      color: isDone
                          ? t.colorScheme.onPrimary
                          : t.colorScheme.primary,
                    ),
                  ),
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
                              task.task,
                              style: t.textTheme.titleMedium?.copyWith(
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDone
                                    ? t.colorScheme.outline
                                    : t.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: t.colorScheme.primaryContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              task.quantity,
                              style: t.textTheme.labelSmall?.copyWith(
                                color: t.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _Row(
                        icon: Icons.check_circle_outline,
                        text: task.purpose,
                        color: t.colorScheme.outline,
                      ),
                      const SizedBox(height: 4),
                      _Row(
                        icon: Icons.ac_unit_outlined,
                        text: task.storage,
                        color: t.colorScheme.outline,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isDone
                        ? t.colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDone
                          ? t.colorScheme.primary
                          : t.colorScheme.outline.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? Icon(Icons.check,
                          size: 16, color: t.colorScheme.onPrimary)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Row({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: t.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
