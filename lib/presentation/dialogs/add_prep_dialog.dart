import 'package:flutter/material.dart';

import '../widgets/form_shell.dart';

class AddPrepResult {
  final String task;
  final String quantity;
  final String purpose;
  final String storage;

  AddPrepResult({
    required this.task,
    required this.quantity,
    required this.purpose,
    required this.storage,
  });
}

Future<AddPrepResult?> showAddPrepDialog({required BuildContext context}) {
  return showAdaptiveForm<AddPrepResult>(
    context: context,
    title: 'Nueva tarea',
    builder: (_) => const _AddPrepForm(),
  );
}

class _AddPrepForm extends StatefulWidget {
  const _AddPrepForm();

  @override
  State<_AddPrepForm> createState() => _AddPrepFormState();
}

class _AddPrepFormState extends State<_AddPrepForm> {
  final _formKey = GlobalKey<FormState>();
  String _task = '';
  String _quantity = '';
  String _purpose = '';
  String _storage = '';

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();
    Navigator.of(context).pop(AddPrepResult(
      task: _task,
      quantity: _quantity,
      purpose: _purpose,
      storage: _storage,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormHeader(title: 'Nueva tarea de preparación'),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormStringField(
                    label: 'Tarea',
                    hint: 'Ej: Cocinar lentejas',
                    required: true,
                    onSaved: (v) => _task = v,
                  ),
                  FormStringField(
                    label: 'Cantidad sugerida',
                    hint: 'Ej: 350 g secas',
                    required: true,
                    onSaved: (v) => _quantity = v,
                  ),
                  FormStringField(
                    label: 'Qué te resuelve',
                    hint: 'Ej: Medallones, albóndigas y ensalada',
                    maxLines: 3,
                    onSaved: (v) => _purpose = v,
                  ),
                  FormStringField(
                    label: 'Conservación',
                    hint: 'Ej: Freezar en porciones',
                    onSaved: (v) => _storage = v,
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
