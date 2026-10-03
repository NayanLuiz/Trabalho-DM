import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/repository/hero_repository.dart';
import 'package:flutter_repository_example/ui/page/home_page.dart';
import 'package:provider/provider.dart';

import 'support/fake_hero_repository.dart';

void main() {
  testWidgets('abre e retorna das quatro opções da Home', (tester) async {
    await tester.pumpWidget(
      Provider<HeroRepository>.value(
        value: FakeHeroRepository([]),
        child: const MaterialApp(home: HomePage()),
      ),
    );

    const sections = <String>[
      'AGENTES',
      'CONTRATO DIÁRIO',
      'MEU ESQUADRÃO',
      'MISSÕES',
    ];

    for (final section in sections) {
      await tester.tap(find.text(section));
      await tester.pumpAndSettle();
      if (section == 'AGENTES') {
        expect(find.text('Nenhum agente encontrado.'), findsOneWidget);
      } else {
        expect(find.text('Em desenvolvimento'), findsOneWidget);
      }

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(section), findsOneWidget);
    }
  });
}
