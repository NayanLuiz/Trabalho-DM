import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/repository/hero_repository.dart';
import 'package:flutter_repository_example/ui/page/heroes_list_page.dart';
import 'package:provider/provider.dart';

import 'support/fake_hero_repository.dart';

void main() {
  testWidgets('lista agentes e abre detalhes', (tester) async {
    final heroes = loadTestHeroes(2);
    final repository = FakeHeroRepository(heroes);
    await tester.pumpWidget(
      Provider<HeroRepository>.value(
        value: repository,
        child: const MaterialApp(home: HeroesListPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(heroes.first.name), findsOneWidget);
    expect(find.text('Força: ${heroes.first.strength}'), findsOneWidget);
    expect(find.text('Velocidade: ${heroes.first.speed}'), findsOneWidget);
    expect(find.text('Poder: ${heroes.first.power}'), findsOneWidget);

    await tester.tap(find.text(heroes.first.name));
    await tester.pumpAndSettle();
    expect(find.text('Atributos'), findsOneWidget);
    expect(find.text('Aparência'), findsOneWidget);
  });

  testWidgets('busca próxima página ao rolar', (tester) async {
    final heroes = loadTestHeroes(11);
    final repository = FakeHeroRepository(heroes);
    await tester.pumpWidget(
      Provider<HeroRepository>.value(
        value: repository,
        child: const MaterialApp(home: HeroesListPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(heroes.last.name),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(repository.requestedPages, containsAllInOrder([1, 2]));
    expect(find.text(heroes.last.name), findsOneWidget);
  });
}
