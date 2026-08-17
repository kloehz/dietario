import 'package:flutter/material.dart';

import '../widgets/form_shell.dart';

class AddShoppingResult {
  final String category;
  final String product;
  final double quantity;
  final String unit;
  final String notes;

  AddShoppingResult({
    required this.category,
    required this.product,
    required this.quantity,
    required this.unit,
    required this.notes,
  });
}

Future<AddShoppingResult?> showAddShoppingDialog({
  required BuildContext context,
  required List<String> existingCategories,
  String? initialCategory,
}) {
  return showAdaptiveForm<AddShoppingResult>(
    context: context,
    title: 'Nuevo producto',
    builder: (_) => _AddShoppingForm(
      existingCategories: existingCategories,
      initialCategory: initialCategory,
    ),
  );
}

class _AddShoppingForm extends StatefulWidget {
  final List<String> existingCategories;
  final String? initialCategory;
  const _AddShoppingForm({
    required this.existingCategories,
    this.initialCategory,
  });

  @override
  State<_AddShoppingForm> createState() => _AddShoppingFormState();
}

class _AddShoppingFormState extends State<_AddShoppingForm> {
  final _formKey = GlobalKey<FormState>();
  final _newCategoryCtrl = TextEditingController();

  late String _category;
  String _product = '';
  double _quantity = 1;
  String _unit = 'kg';
  String _notes = '';

  static const _commonUnits = [
    'kg',
    'g',
    'l',
    'ml',
    'unidades',
    'latas',
    'frasco',
    'paquete',
    'atados',
    'panes',
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ??
        (widget.existingCategories.isNotEmpty
            ? widget.existingCategories.first
            : 'Otros');
  }

  @override
  void dispose() {
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();
    final cat = _category == '__new__' ? _newCategoryCtrl.text.trim() : _category;
    if (cat.isEmpty) return;
    Navigator.of(context).pop(AddShoppingResult(
      category: cat,
      product: _product,
      quantity: _quantity,
      unit: _unit,
      notes: _notes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final catOptions = [
      ...widget.existingCategories,
      '__new__',
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormHeader(title: 'Nuevo producto'),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormPickerField<String>(
                    label: 'Categoría',
                    value: _category,
                    options: catOptions,
                    labelOf: (c) => c == '__new__' ? '+ Nueva' : c,
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  if (_category == '__new__')
                    FormStringField(
                      label: 'Nombre de la nueva categoría',
                      required: true,
                      onSaved: (_) {},
                    ),
                  FormStringField(
                    label: 'Producto',
                    required: true,
                    onSaved: (v) => _product = v,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FormNumberField(
                          label: 'Cantidad',
                          initialValue: _quantity.toString(),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            return double.tryParse(
                                    v.trim().replaceAll(',', '.')) ==
                                null
                                ? 'Número'
                                : null;
                          },
                          onSaved: (v) => _quantity = v,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FormPickerField<String>(
                          label: 'Unidad',
                          value: _unit,
                          options: _commonUnits,
                          labelOf: (u) => u,
                          onChanged: (v) => setState(() => _unit = v),
                        ),
                      ),
                    ],
                  ),
                  FormStringField(
                    label: 'Notas (opcional)',
                    hint: 'Ej: Para el menú del lunes',
                    onSaved: (v) => _notes = v,
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
