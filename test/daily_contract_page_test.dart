import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/repository/hero_repository.dart';
import 'package:flutter_repository_example/ui/page/daily_contract_page.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:provider/provider.dart';

import 'support/fake_hero_repository.dart';

void main() {
  Widget contract(FakeHeroRepository repository) =>
      Provider<HeroRepository>.value(
        value: repository,
        child: const MaterialApp(home: DailyContractPage()),
      );

  testWidgets('mostra agente diário e recruta uma única vez', (tester) async {
    final hero = loadTestHeroes(1).first;
    final repository = FakeHeroRepository([hero]);
    await tester.pumpWidget(contract(repository));
    await tester.pumpAndSettle();

    expect(find.text(hero.name), findsOneWidget);
    expect(find.byType(PrimerProgressBar), findsNWidgets(6));
    expect(find.text('Esquadrão: 0/15'), findsOneWidget);

    await tester.ensureVisible(find.text('Recrutar para o Esquadrão'));
    await tester.tap(find.text('Recrutar para o Esquadrão'));
    await tester.pumpAndSettle();

    expect(repository.recruitedIds, contains(hero.id));
    expect(repository.recruitCalls, 1);
    expect(find.text('Esquadrão: 1/15'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Já está no Esquadrão'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('impede recrutamento quando já há 15 agentes', (tester) async {
    final hero = loadTestHeroes(1).first;
    final repository = FakeHeroRepository([
      hero,
    ], initialSquadIds: List.generate(15, (index) => index + 1000).toSet());
    await tester.pumpWidget(contract(repository));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Recrutar para o Esquadrão'));
    await tester.tap(find.text('Recrutar para o Esquadrão'));
    await tester.pump();

    expect(find.text('O esquadrão já tem 15 agentes.'), findsOneWidget);
    expect(repository.recruitCalls, 0);
    expect(repository.recruitedIds, isNot(contains(hero.id)));
  });

  testWidgets('mostra agente já recrutado sem duplicar', (tester) async {
    final hero = loadTestHeroes(1).first;
    final repository = FakeHeroRepository([hero], initialSquadIds: {hero.id});
    await tester.pumpWidget(contract(repository));
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Já está no Esquadrão'),
    );
    expect(button.onPressed, isNull);
    expect(repository.recruitCalls, 0);
    expect(find.text('Esquadrão: 1/15'), findsOneWidget);
  });
}
