import 'package:flutter/material.dart';

import '../../domain/hero.dart' as domain;

class HeroDetailsPage extends StatelessWidget {
  final domain.Hero hero;

  const HeroDetailsPage({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: const Center(child: Text('Detalhes completos na próxima fase.')),
    );
  }
}
