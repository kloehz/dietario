import 'package:flutter/material.dart';

import '../../domain/entities/day_meal.dart';
import '../widgets/form_shell.dart';

class AddMealResult {
  final String day;
  final MealSlot slot;
  final String text;
  final String? menuCode;
  final String? note;

  AddMealResult({
    required this.day,
    required this.slot,
    required this.text,
    this.menuCode,
    this.note,
  });
}

Future<AddMealResult?> showAddMealDialog({
  required BuildContext context,
  String? initialDay,
  MealSlot? initialSlot,
}) {
  return showAdaptiveForm<AddMealResult>(
    context: context,
    title: 'Nueva comida',
    builder: (_) => _AddMealForm(initialDay: initialDay, initialSlot: initialSlot),
  );
}

class _AddMealForm extends StatefulWidget {
  final String? initialDay;
  final MealSlot? initialSlot;
  const _AddMealForm({this.initialDay, this.initialSlot});

  @override
  State<_AddMealForm> createState() => _AddMealFormState();
}

class _AddMealFormState extends State<_AddMealForm> {
  static const _days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  final _formKey = GlobalKey<FormState>();
  late String _day;
  late MealSlot _slot;
  String _text = '';
  String _menuCode = '';
  String _note = '';

  @override
  void initState() {
    super.initState();
    _day = widget.initialDay ?? _days.first;
    _slot = widget.initialSlot ?? MealSlot.almuerzo;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();
    Navigator.of(context).pop(AddMealResult(
      day: _day,
      slot: _slot,
      text: _text,
      menuCode: _menuCode.isEmpty ? null : _menuCode,
      note: _note.isEmpty ? null : _note,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormHeader(title: 'Nueva comida'),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormPickerField<String>(
                    label: 'Día',
                    value: _day,
                    options: _days,
                    labelOf: (d) => d,
                    onChanged: (v) => setState(() => _day = v),
                  ),
                  FormPickerField<MealSlot>(
                    label: 'Comida',
                    value: _slot,
                    options: MealSlot.values,
                    labelOf: (s) => s.label,
                    onChanged: (v) => setState(() => _slot = v),
                  ),
                  FormStringField(
                    label: 'Descripción',
                    hint: 'Ej: Ensalada de lentejas + huevo duro',
                    maxLines: 4,
                    required: true,
                    onSaved: (v) => _text = v,
                  ),
                  FormStringField(
                    label: 'Código de menú (opcional)',
                    hint: 'Ej: MENÚ 8',
                    onSaved: (v) => _menuCode = v,
                  ),
                  FormStringField(
                    label: 'Nota rápida (opcional)',
                    onSaved: (v) => _note = v,
                  ),
                ],
              ),
            ),
          ),
        ),
        FormActions(onSubmit: _submit),
      ],
    );
  }
}
