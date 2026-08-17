import 'package:dietario/presentation/pages/home_shell_page.dart';
import 'package:dietario/presentation/widgets/fab_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders the page action registered by a descendant', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FabController(),
        child: MaterialApp(
          home: HomeShellPage(
            currentIndex: 0,
            child: FabActionScope(
              onAdd: () {},
              icon: Icons.add,
              label: 'Comida',
              child: const SizedBox(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Comida'), findsOneWidget);
  });
}
