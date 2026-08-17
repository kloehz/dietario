import 'package:flutter/material.dart';

import '../widgets/form_shell.dart';

class AddRecipeResult {
  final String day;
  final String meal;
  final String name;
  final String ingredients;
  final String preparation;
  final String origin;

  AddRecipeResult({
    required this.day,
    required this.meal,
    required this.name,
    required this.ingredients,
    required this.preparation,
    required this.origin,
  });
}

Future<AddRecipeResult?> showAddRecipeDialog({
  required BuildContext context,
  required List<String> existingDays,
  String? initialDay,
}) {
  return showAdaptiveForm<AddRecipeResult>(
    context: context,
    title: 'Nueva receta',
    builder: (_) => _AddRecipeForm(
      existingDays: existingDays,
      initialDay: initialDay,
    ),
  );
}

class _AddRecipeForm extends StatefulWidget {
  final List<String> existingDays;
  final String? initialDay;
  const _AddRecipeForm({required this.existingDays, this.initialDay});

  @override
  State<_AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<_AddRecipeForm> {
  final _formKey = GlobalKey<FormState>();

  static const _defaultDays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
    'Base',
  ];

  late String _day;
  late String _meal;
  String _name = '';
  String _ingredients = '';
  String _preparation = '';
  String _origin = '';

  @override
  void initState() {
    super.initState();
    final days = widget.existingDays.isNotEmpty
        ? widget.existingDays
        : _defaultDays;
    _day = widget.initialDay ?? days.first;
    _meal = 'Almuerzo';
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();
    Navigator.of(context).pop(AddRecipeResult(
      day: _day,
      meal: _meal,
      name: _name,
      ingredients: _ingredients,
      preparation: _preparation,
      origin: _origin,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.existingDays.isNotEmpty
        ? widget.existingDays
        : _defaultDays;
    const meals = ['Almuerzo', 'Cena', 'Desayuno', 'Merienda', 'Desayuno/Merienda'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormHeader(title: 'Nueva receta'),
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
                    options: days,
                    labelOf: (d) => d,
                    onChanged: (v) => setState(() => _day = v),
                  ),
                  FormPickerField<String>(
                    label: 'Comida',
                    value: _meal,
                    options: meals,
                    labelOf: (m) => m,
                    onChanged: (v) => setState(() => _meal = v),
                  ),
                  FormStringField(
                    label: 'Nombre',
                    required: true,
                    onSaved: (v) => _name = v,
                  ),
                  FormStringField(
                    label: 'Ingredientes para 2',
                    hint: '4 huevos; 200 g espinaca; 80 g queso magro...',
                    maxLines: 4,
                    required: true,
                    onSaved: (v) => _ingredients = v,
                  ),
                  FormStringField(
                    label: 'Preparación',
                    hint: '1) ... 2) ... 3) ...',
                    maxLines: 6,
                    required: true,
                    onSaved: (v) => _preparation = v,
                  ),
                  FormStringField(
                    label: 'Origen (opcional)',
                    hint: 'Ej: Recetario legumbrero',
                    onSaved: (v) => _origin = v,
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
