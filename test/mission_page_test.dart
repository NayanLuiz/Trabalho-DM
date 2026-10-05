import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/repository/hero_repository.dart';
import 'package:flutter_repository_example/domain/hero.dart' as domain;
import 'package:flutter_repository_example/ui/page/mission_page.dart';
import 'package:provider/provider.dart';

import 'support/fake_hero_repository.dart';

void main() {
  Widget mission(FakeHeroRepository repository) =>
      Provider<HeroRepository>.value(
        value: repository,
        child: const MaterialApp(home: MissionPage()),
      );

  domain.Hero withStats(domain.Hero hero, int value) => hero.copyWith(
    intelligence: value,
    strength: value,
    speed: value,
    durability: value,
    power: value,
    combat: value,
  );

  FakeHeroRepository repositoryWithStats(int agentValue, int enemyValue) {
    final source = loadTestHeroes(6);
    final heroes = [
      ...source.take(5).map((hero) => withStats(hero, agentValue)),
      withStats(source.last, enemyValue),
    ];
    return FakeHeroRepository(
      heroes,
      initialSquadIds: heroes.take(5).map((hero) => hero.id).toSet(),
    );
  }

  Future<int> playAllRounds(
    WidgetTester tester,
    FakeHeroRepository repository,
    String result,
  ) async {
    final roundText = tester
        .widget<Text>(find.textContaining('ROUND 1 /'))
        .data!;
    final totalRounds = int.parse(roundText.split('/').last.trim());
    expect(totalRounds, inInclusiveRange(3, 5));

    for (var index = 0; index < totalRounds; index++) {
      final agent = find.byKey(
        ValueKey('mission-hero-${repository.heroes[index].id}'),
      );
      await tester.ensureVisible(agent);
      await tester.tap(agent);
      await tester.pumpAndSettle();
      expect(find.text(result), findsOneWidget);

      if (index < totalRounds - 1) {
        await tester.ensureVisible(find.text('Próximo round'));
        await tester.tap(find.text('Próximo round'));
        await tester.pumpAndSettle();
        expect(find.text('ROUND ${index + 2} / $totalRounds'), findsOneWidget);
        final usedAgent = find.byKey(
          ValueKey('mission-hero-${repository.heroes[index].id}'),
        );
        expect(tester.widget<InkWell>(usedAgent).onTap, isNull);
      }
    }

    await tester.ensureVisible(find.text('Ver resultado'));
    await tester.tap(find.text('Ver resultado'));
    await tester.pumpAndSettle();
    expect(find.text('Resumo da missão'), findsOneWidget);
    return totalRounds;
  }

  testWidgets('exige cinco agentes antes de buscar inimigos', (tester) async {
    final heroes = loadTestHeroes(4);
    final repository = FakeHeroRepository(
      heroes,
      initialSquadIds: heroes.map((hero) => hero.id).toSet(),
    );
    await tester.pumpWidget(mission(repository));
    await tester.pumpAndSettle();

    expect(find.text('Você precisa de pelo menos 5 agentes.'), findsOneWidget);
    expect(repository.requestedPages, isEmpty);
  });

  testWidgets('3–5 rounds, agente único e bônus salvo após maioria', (
    tester,
  ) async {
    final repository = repositoryWithStats(100, 0);
    await tester.pumpWidget(mission(repository));
    await tester.pumpAndSettle();

    expect(find.text(repository.heroes.last.name), findsOneWidget);
    expect(find.text('Escolha seu agente'), findsOneWidget);
    expect(find.textContaining(' × '), findsNothing);
    expect(repository.requestedPages, [1]);
    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(
      (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
          .crossAxisCount,
      3,
    );

    final total = await playAllRounds(tester, repository, 'Vitória!');
    expect(find.text('Missão Cumprida!'), findsOneWidget);
    expect(find.text('Vitórias: $total'), findsOneWidget);
    expect(find.text('Derrotas: 0'), findsOneWidget);
    expect(find.text('Empates: 0'), findsOneWidget);
    expect(repository.updateCalls, 1);
    final saved = repository.updatedHero!;
    expect(repository.recruitedIds, contains(saved.id));
    expect(
      [
        saved.intelligence,
        saved.strength,
        saved.speed,
        saved.durability,
        saved.power,
        saved.combat,
      ].where((value) => value == 101).length,
      1,
    );
  });

  testWidgets('maioria de derrotas mostra erro e não concede bônus', (
    tester,
  ) async {
    final repository = repositoryWithStats(0, 100);
    await tester.pumpWidget(mission(repository));
    await tester.pumpAndSettle();

    final total = await playAllRounds(tester, repository, 'Derrota!');
    expect(find.text('Operação Fracassada!'), findsOneWidget);
    expect(find.text('Derrotas: $total'), findsOneWidget);
    expect(repository.updateCalls, 0);
  });

  testWidgets('empate geral mostra aviso e não concede bônus', (tester) async {
    final repository = repositoryWithStats(50, 50);
    await tester.pumpWidget(mission(repository));
    await tester.pumpAndSettle();

    final total = await playAllRounds(tester, repository, 'Empate!');
    expect(find.text('Missão Empatada!'), findsOneWidget);
    expect(find.text('Empates: $total'), findsOneWidget);
    expect(repository.updateCalls, 0);
  });

  testWidgets('sem inimigo fora do esquadrão mostra erro', (tester) async {
    final heroes = loadTestHeroes(5);
    final repository = FakeHeroRepository(
      heroes,
      initialSquadIds: heroes.map((hero) => hero.id).toSet(),
    );
    await tester.pumpWidget(mission(repository));
    await tester.pumpAndSettle();

    expect(
      find.text('Nenhum inimigo disponível fora do esquadrão.'),
      findsOneWidget,
    );
  });

  testWidgets('grid de três colunas cabe em tela estreita', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = repositoryWithStats(50, 50);
    await tester.pumpWidget(mission(repository));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
