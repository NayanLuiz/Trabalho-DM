import 'package:flutter/material.dart';

import '../../domain/hero.dart' as domain;
import 'hero_details_page.dart';

class SquadHeroDetailsPage extends StatelessWidget {
  final domain.Hero hero;

  const SquadHeroDetailsPage({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return HeroDetailsPage(hero: hero);
  }
}
