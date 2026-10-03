import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/ui/page/home_page.dart';

void main() {
  testWidgets('abre e retorna das quatro opções da Home', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    const sections = <String>[
      'AGENTES',
      'CONTRATO DIÁRIO',
      'MEU ESQUADRÃO',
      'MISSÕES',
    ];

    for (final section in sections) {
      await tester.tap(find.text(section));
      await tester.pumpAndSettle();
      expect(find.text('Em desenvolvimento'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(section), findsOneWidget);
    }
  });
}
