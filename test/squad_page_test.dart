import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/repository/hero_repository.dart';
import 'package:flutter_repository_example/ui/page/squad_page.dart';
import 'package:provider/provider.dart';

import 'support/fake_hero_repository.dart';

void main() {
  Widget squad(FakeHeroRepository repository) => Provider<HeroRepository>.value(
    value: repository,
    child: const MaterialApp(home: SquadPage()),
  );

  testWidgets('mostra estado vazio sem agentes recrutados', (tester) async {
    final repository = FakeHeroRepository(loadTestHeroes(1));
    await tester.pumpWidget(squad(repository));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum agente no esquadrão.'), findsOneWidget);
    expect(repository.squadReads, 1);
  });

  testWidgets('mostra melhor atributo e abre detalhe do membro', (
    tester,
  ) async {
    final heroes = loadTestHeroes(2);
    final repository = FakeHeroRepository(
      heroes,
      initialSquadIds: heroes.map((hero) => hero.id).toSet(),
    );
    await tester.pumpWidget(squad(repository));
    await tester.pumpAndSettle();

    expect(find.text('Agentes: 2/15'), findsOneWidget);
    expect(find.text(heroes.first.name), findsOneWidget);
    expect(find.text(heroes.last.name), findsOneWidget);
    expect(find.text('Melhor atributo: Força: 100'), findsOneWidget);

    await tester.tap(find.text(heroes.first.name));
    await tester.pumpAndSettle();
    expect(find.text('Atributos'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(repository.squadReads, 2);
  });

  testWidgets('exibe a capacidade máxima de quinze agentes', (tester) async {
    final heroes = loadTestHeroes(15);
    final repository = FakeHeroRepository(
      heroes,
      initialSquadIds: heroes.map((hero) => hero.id).toSet(),
    );
    await tester.pumpWidget(squad(repository));
    await tester.pumpAndSettle();

    expect(find.text('Agentes: 15/15'), findsOneWidget);
  });

  testWidgets('cancelar mantém agente; confirmar dispensa e atualiza lista', (
    tester,
  ) async {
    final hero = loadTestHeroes(1).first;
    final repository = FakeHeroRepository([hero], initialSquadIds: {hero.id});
    await tester.pumpWidget(squad(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text(hero.name));
    await tester.pumpAndSettle();

    await tester.tap(find.text('DISPENSAR DO ESQUADRÃO'));
    await tester.pumpAndSettle();
    expect(find.text('Deseja dispensar este agente?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repository.recruitedIds, contains(hero.id));
    expect(repository.dismissCalls, 0);
    expect(find.text('DISPENSAR DO ESQUADRÃO'), findsOneWidget);

    await tester.tap(find.text('DISPENSAR DO ESQUADRÃO'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dispensar'));
    await tester.pumpAndSettle();
    expect(repository.recruitedIds, isNot(contains(hero.id)));
    expect(repository.dismissCalls, 1);
    expect(find.text('Nenhum agente no esquadrão.'), findsOneWidget);
    expect(repository.squadReads, 2);
  });
}
