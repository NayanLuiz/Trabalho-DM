import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/repository/hero_repository.dart';
import 'package:flutter_repository_example/domain/hero.dart' as domain;
import 'package:flutter_repository_example/ui/page/mission_first_round_page.dart';
import 'package:provider/provider.dart';

import 'support/fake_hero_repository.dart';

void main() {
  Widget mission(FakeHeroRepository repository) =>
      Provider<HeroRepository>.value(
        value: repository,
        child: const MaterialApp(home: MissionFirstRoundPage()),
      );

  domain.Hero withStats(domain.Hero hero, int value) => hero.copyWith(
    intelligence: value,
    strength: value,
    speed: value,
    durability: value,
    power: value,
    combat: value,
  );

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

  testWidgets('primeiro round oculta valor inimigo até a escolha', (
    tester,
  ) async {
    final source = loadTestHeroes(6);
    final heroes = [
      ...source.take(5).map((hero) => withStats(hero, 100)),
      withStats(source.last, 0),
    ];
    final repository = FakeHeroRepository(
      heroes,
      initialSquadIds: heroes.take(5).map((hero) => hero.id).toSet(),
    );
    await tester.pumpWidget(mission(repository));
    await tester.pumpAndSettle();

    final round = tester.widget<Text>(find.textContaining('ROUND 1 /')).data!;
    expect(int.parse(round.split('/').last.trim()), inInclusiveRange(3, 5));
    expect(find.text(source.last.name), findsOneWidget);
    expect(find.text('Escolha seu agente'), findsOneWidget);
    expect(find.textContaining('Inimigo:'), findsNothing);
    expect(repository.requestedPages, [1]);
    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(
      (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
          .crossAxisCount,
      3,
    );

    final firstAgent = find.byKey(ValueKey('mission-agent-${heroes.first.id}'));
    await tester.ensureVisible(firstAgent);
    await tester.tap(firstAgent);
    await tester.pumpAndSettle();

    expect(find.text('Vitória!'), findsOneWidget);
    expect(find.text('Inimigo: 0'), findsOneWidget);
    expect(tester.widget<InkWell>(firstAgent).onTap, isNull);
  });

  testWidgets('compara derrota e empate sem regra extra', (tester) async {
    final source = loadTestHeroes(6);
    for (final (agentValue, enemyValue, expected) in [
      (0, 100, 'Derrota!'),
      (50, 50, 'Empate!'),
    ]) {
      final heroes = [
        ...source.take(5).map((hero) => withStats(hero, agentValue)),
        withStats(source.last, enemyValue),
      ];
      final repository = FakeHeroRepository(
        heroes,
        initialSquadIds: heroes.take(5).map((hero) => hero.id).toSet(),
      );
      await tester.pumpWidget(mission(repository));
      await tester.pumpAndSettle();

      final agent = find.byKey(ValueKey('mission-agent-${heroes.first.id}'));
      await tester.ensureVisible(agent);
      await tester.tap(agent);
      await tester.pumpAndSettle();
      expect(find.text(expected), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('informa quando só há heróis do esquadrão no cache', (
    tester,
  ) async {
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
}
