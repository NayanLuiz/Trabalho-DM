import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/hero.dart' as domain;
import '../page/hero_details_page.dart';

class HeroCard extends StatelessWidget {
  final domain.Hero hero;

  const HeroCard({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => HeroDetailsPage(hero: hero)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: hero.imageSm,
                width: 100,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (_, _) => const SizedBox(
                  width: 100,
                  height: 120,
                  child: Icon(Icons.image),
                ),
                errorWidget: (_, _, _) => const SizedBox(
                  width: 100,
                  height: 120,
                  child: Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Força: ${hero.strength}'),
                    Text('Velocidade: ${hero.speed}'),
                    Text('Poder: ${hero.power}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
