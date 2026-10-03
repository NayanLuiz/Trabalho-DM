import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/hero.dart' as domain;

class SquadAgentWidget extends StatelessWidget {
  final domain.Hero hero;
  final VoidCallback onTap;

  const SquadAgentWidget({super.key, required this.hero, required this.onTap});

  String _bestAttribute() {
    final attributes = <String, int>{
      'Inteligência': hero.intelligence,
      'Força': hero.strength,
      'Velocidade': hero.speed,
      'Durabilidade': hero.durability,
      'Poder': hero.power,
      'Combate': hero.combat,
    };
    final best = attributes.entries.reduce(
      (current, next) => next.value > current.value ? next : current,
    );
    return '${best.key}: ${best.value}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: hero.imageSm,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(Icons.person),
                  ),
                  errorWidget: (_, _, _) => const SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(Icons.person_off),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('Melhor atributo: ${_bestAttribute()}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
