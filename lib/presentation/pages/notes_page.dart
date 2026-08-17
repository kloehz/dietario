import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/plan_note.dart';
import '../controllers/notes_controller.dart';
import '../dialogs/add_note_dialog.dart';
import '../widgets/fab_scope.dart';
import '../widgets/section_header.dart';
import 'home_shell_page.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  Future<void> _add(BuildContext context) async {
    final result = await showAddNoteDialog(context: context);
    if (result == null || !context.mounted) return;
    await context.read<NotesController>().add(
          topic: result.topic,
          respected: result.respected,
          applied: result.applied,
          source: result.source,
        );
  }

  Future<void> _confirmDelete(BuildContext context, PlanNote note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text('¿Eliminar "${note.topic}"?'),
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
    await context.read<NotesController>().remove(note.id);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotesController>();
    return FabActionScope(
      onAdd: () => _add(context),
      icon: Icons.note_add,
      label: 'Nota',
      child: PageScaffold(
        title: 'Notas del plan',
        subtitle: 'Criterios y base',
        banner: const InfoBanner(
          icon: Icons.flag_outlined,
          text: 'Cómo se traduce el plan alimentario a este menú semanal.',
        ),
        child: controller.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                itemCount: controller.notes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _NoteCard(
                  note: controller.notes[i],
                  onDelete: () => _confirmDelete(context, controller.notes[i]),
                ),
              ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final PlanNote note;
  final VoidCallback onDelete;
  const _NoteCard({required this.note, required this.onDelete});

  IconData _icon(String topic) {
    final t = topic.toLowerCase();
    if (t.contains('fruta') || t.contains('verdur')) return Icons.eco_outlined;
    if (t.contains('prote')) return Icons.fitness_center_outlined;
    if (t.contains('legumbre')) return Icons.spa_outlined;
    if (t.contains('cereal')) return Icons.grain_outlined;
    if (t.contains('grasa')) return Icons.opacity_outlined;
    if (t.contains('ultraprocesado')) return Icons.no_food_outlined;
    if (t.contains('menú')) return Icons.menu_book_outlined;
    return Icons.notes_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final color = t.colorScheme.primary;
    return GestureDetector(
      onLongPress: onDelete,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(_icon(note.topic), color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.topic, style: t.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _Row(
                      label: 'Qué se respetó',
                      body: note.respected,
                      color: t.colorScheme.outline,
                    ),
                    const SizedBox(height: 6),
                    _Row(
                      label: 'Aplicación en este plan',
                      body: note.applied,
                      color: t.colorScheme.onSurface,
                    ),
                    if (note.source.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: t.colorScheme.secondaryContainer
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note.source,
                          style: t.textTheme.labelSmall?.copyWith(
                            color: t.colorScheme.onSecondaryContainer,
                          ),
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

class _Row extends StatelessWidget {
  final String label;
  final String body;
  final Color color;
  const _Row({required this.label, required this.body, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.primary),
        ),
        const SizedBox(height: 2),
        Text(body, style: t.textTheme.bodyMedium?.copyWith(color: color)),
      ],
    );
  }
}
