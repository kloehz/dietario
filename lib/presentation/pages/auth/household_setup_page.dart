import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/household_controller.dart';

class HouseholdSetupPage extends StatefulWidget {
  const HouseholdSetupPage({super.key});

  @override
  State<HouseholdSetupPage> createState() => _HouseholdSetupPageState();
}

class _HouseholdSetupPageState extends State<HouseholdSetupPage> {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Tu hogar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<AuthController>().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Plan para vos y tu pareja',
                    style: t.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Para sincronizar entre los dos, creá un hogar nuevo o unite con el código que te pasó tu pareja.',
                    style: t.textTheme.bodyMedium
                        ?.copyWith(color: t.colorScheme.outline),
                  ),
                  const SizedBox(height: 24),
                  _CreateCard(),
                  const SizedBox(height: 14),
                  _JoinCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateCard extends StatefulWidget {
  @override
  State<_CreateCard> createState() => _CreateCardState();
}

class _CreateCardState extends State<_CreateCard> {
  final _ctrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Ponele un nombre');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<HouseholdController>().create(name: name);
      if (mounted) context.go('/menu');
    } catch (e, st) {
      debugPrint('[auth] create household failed: $e\n$st');
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home_outlined, color: t.colorScheme.primary),
                const SizedBox(width: 10),
                Text('Crear un hogar nuevo',
                    style: t.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Te generamos un código de 6 caracteres para compartir con tu pareja.',
              style: t.textTheme.bodySmall
                  ?.copyWith(color: t.colorScheme.outline),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                labelText: 'Nombre (ej: Nuestro hogar)',
                filled: true,
                fillColor: t.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: t.colorScheme.error, fontSize: 12)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : _submit,
                icon: const Icon(Icons.add),
                label: Text(_busy ? 'Creando...' : 'Crear'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinCard extends StatefulWidget {
  @override
  State<_JoinCard> createState() => _JoinCardState();
}

class _JoinCardState extends State<_JoinCard> {
  final _ctrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _ctrl.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _error = 'El código tiene 6 letras/números');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<HouseholdController>().joinByCode(code: code);
      if (mounted) context.go('/menu');
    } on FormatException {
      setState(() => _error = 'Código inválido. Pedile el código a tu pareja.');
    } catch (e, st) {
      debugPrint('[auth] join failed: $e\n$st');
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group_outlined, color: t.colorScheme.primary),
                const SizedBox(width: 10),
                Text('Unirme con código', style: t.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Tu pareja tiene que pasarte el código de 6 caracteres que ve en su app.',
              style: t.textTheme.bodySmall
                  ?.copyWith(color: t.colorScheme.outline),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z0-9]'),
                ),
                _UpperCaseFormatter(),
              ],
              style: const TextStyle(
                fontSize: 22,
                letterSpacing: 4,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                counterText: '',
                labelText: 'Código',
                hintText: 'ABC123',
                filled: true,
                fillColor: t.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: t.colorScheme.error, fontSize: 12)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : _submit,
                icon: const Icon(Icons.login),
                label: Text(_busy ? 'Uniéndome...' : 'Unirme'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
