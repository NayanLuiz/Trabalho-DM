import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/ui/page/hero_details_page.dart';
import 'package:flutter_repository_example/ui/widgets/powerstat_widget.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

import 'support/fake_hero_repository.dart';

void main() {
  testWidgets('mostra imagem, seis atributos e todos os dados do herói', (
    tester,
  ) async {
    final hero = loadTestHeroes(1).first;
    await tester.pumpWidget(MaterialApp(home: HeroDetailsPage(hero: hero)));
    await tester.pumpAndSettle();

    expect(find.byType(PrimerProgressBar), findsNWidgets(6));
    for (final section in [
      'Atributos',
      'Aparência',
      'Biografia',
      'Trabalho',
      'Conexões',
    ]) {
      expect(find.text(section), findsOneWidget);
    }

    expect(find.text('Inteligência'), findsOneWidget);
    expect(find.text('Força'), findsOneWidget);
    expect(find.text('Velocidade'), findsOneWidget);
    expect(find.text('Durabilidade'), findsOneWidget);
    expect(find.text('Poder'), findsOneWidget);
    expect(find.text('Combate'), findsOneWidget);
    expect(find.textContaining(hero.fullName), findsWidgets);
    expect(find.textContaining(hero.occupation), findsOneWidget);
    expect(find.textContaining(hero.groupAffiliation), findsOneWidget);
    expect(find.textContaining(hero.relatives), findsOneWidget);
    expect(find.text('DISPENSAR DO ESQUADRÃO'), findsNothing);
  });

  testWidgets('barra limita desenho a 100 sem esconder bônus', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              PowerstatWidget(label: 'Poder', value: 101),
              PowerstatWidget(label: 'Combate', value: 0),
            ],
          ),
        ),
      ),
    );

    final bars = tester.widgetList<PrimerProgressBar>(
      find.byType(PrimerProgressBar),
    );
    expect(bars.map((bar) => bar.segments.single.value), [100, 0]);
    expect(find.text('101'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
