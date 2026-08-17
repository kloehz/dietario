import 'package:flutter/material.dart';

/// Opens an adaptive container (bottom sheet on phones, centered dialog on
/// web/tablet). [builder] is responsible for rendering the form, its buttons,
/// and calling `Navigator.pop(context, result)` itself.
Future<T?> showAdaptiveForm<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
}) {
  final isWide = MediaQuery.of(context).size.width >= 720;
  final body = Builder(builder: builder);

  if (isWide) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: body,
          ),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: body,
        ),
      ),
    ),
  );
}

/// Convenience widget: title row with a close button on the right.
class FormHeader extends StatelessWidget {
  final String title;
  const FormHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Expanded(child: Text(title, style: t.textTheme.titleLarge)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }
}

/// Cancel/Submit row used at the bottom of every form.
class FormActions extends StatelessWidget {
  final String submitLabel;
  final String cancelLabel;
  final VoidCallback onSubmit;
  const FormActions({
    super.key,
    required this.onSubmit,
    this.submitLabel = 'Agregar',
    this.cancelLabel = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(cancelLabel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-line text input.
class FormStringField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final String? hint;
  final void Function(String) onSaved;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool required;

  const FormStringField({
    super.key,
    required this.label,
    required this.onSaved,
    this.initialValue,
    this.hint,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null
            : validator,
        onSaved: (v) => onSaved((v ?? '').trim()),
      ),
    );
  }
}

/// Numeric input that emits a `double`.
class FormNumberField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final String? hint;
  final void Function(double) onSaved;
  final String? Function(String?)? validator;

  const FormNumberField({
    super.key,
    required this.label,
    required this.onSaved,
    this.initialValue,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
        onSaved: (v) {
          final raw = (v ?? '').trim().replaceAll(',', '.');
          onSaved(double.tryParse(raw) ?? 0);
        },
      ),
    );
  }
}

/// Segmented picker for a fixed list of values.
class FormPickerField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final void Function(T) onChanged;
  final IconData Function(T)? iconOf;

  const FormPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    this.iconOf,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final opt in options)
                _PickerChip(
                  label: labelOf(opt),
                  icon: iconOf?.call(opt),
                  selected: opt == value,
                  onTap: () => onChanged(opt),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  const _PickerChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? t.colorScheme.primary
              : t.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: selected
                      ? t.colorScheme.onPrimary
                      : t.colorScheme.primary),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: t.textTheme.labelSmall?.copyWith(
                color: selected ? t.colorScheme.onPrimary : t.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
