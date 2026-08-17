import 'package:flutter/material.dart';

import '../widgets/form_shell.dart';

class AddNoteResult {
  final String topic;
  final String respected;
  final String applied;
  final String source;

  AddNoteResult({
    required this.topic,
    required this.respected,
    required this.applied,
    required this.source,
  });
}

Future<AddNoteResult?> showAddNoteDialog({required BuildContext context}) {
  return showAdaptiveForm<AddNoteResult>(
    context: context,
    title: 'Nueva nota del plan',
    builder: (_) => const _AddNoteForm(),
  );
}

class _AddNoteForm extends StatefulWidget {
  const _AddNoteForm();

  @override
  State<_AddNoteForm> createState() => _AddNoteFormState();
}

class _AddNoteFormState extends State<_AddNoteForm> {
  final _formKey = GlobalKey<FormState>();
  String _topic = '';
  String _respected = '';
  String _applied = '';
  String _source = '';

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();
    Navigator.of(context).pop(AddNoteResult(
      topic: _topic,
      respected: _respected,
      applied: _applied,
      source: _source,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormHeader(title: 'Nueva nota del plan'),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormStringField(
                    label: 'Tema',
                    hint: 'Ej: Hidratación',
                    required: true,
                    onSaved: (v) => _topic = v,
                  ),
                  FormStringField(
                    label: 'Qué se respetó',
                    maxLines: 4,
                    required: true,
                    onSaved: (v) => _respected = v,
                  ),
                  FormStringField(
                    label: 'Aplicación en este plan',
                    maxLines: 3,
                    required: true,
                    onSaved: (v) => _applied = v,
                  ),
                  FormStringField(
                    label: 'Fuente',
                    hint: 'Ej: Plan alimentario',
                    onSaved: (v) => _source = v,
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
