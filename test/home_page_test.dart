import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/repository/hero_repository.dart';
import 'package:flutter_repository_example/ui/page/home_page.dart';
import 'package:provider/provider.dart';

import 'support/fake_hero_repository.dart';

void main() {
  testWidgets('abre e retorna das quatro opções da Home', (tester) async {
    final hero = loadTestHeroes(1).first;
    await tester.pumpWidget(
      Provider<HeroRepository>.value(
        value: FakeHeroRepository([hero]),
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
        expect(find.text(hero.name), findsOneWidget);
      } else if (section == 'CONTRATO DIÁRIO') {
        expect(find.text('Recrutar para o Esquadrão'), findsOneWidget);
      } else if (section == 'MEU ESQUADRÃO') {
        expect(find.text('Nenhum agente no esquadrão.'), findsOneWidget);
      } else {
        expect(
          find.text('Você precisa de pelo menos 5 agentes.'),
          findsOneWidget,
        );
      }

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(section), findsOneWidget);
    }
  });
}
