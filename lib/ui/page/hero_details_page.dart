import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/hero.dart' as domain;
import '../widgets/powerstat_widget.dart';

class HeroDetailsPage extends StatelessWidget {
  final domain.Hero hero;
  final Widget? bottomAction;

  const HeroDetailsPage({super.key, required this.hero, this.bottomAction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      bottomNavigationBar: bottomAction == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: bottomAction,
              ),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: hero.imageLg,
                          width: 260,
                          height: 300,
                          fit: BoxFit.contain,
                          placeholder: (_, _) => const SizedBox(
                            width: 260,
                            height: 300,
                            child: Icon(Icons.image, size: 72),
                          ),
                          errorWidget: (_, _, _) => const SizedBox(
                            width: 260,
                            height: 300,
                            child: Icon(Icons.image_not_supported, size: 72),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hero.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(hero.fullName, textAlign: TextAlign.center),
                        Text(hero.publisher ?? 'Editora não informada'),
                        Text('Alinhamento: ${hero.alignment}'),
                      ],
                    ),
                  ),
                ),
                _section(context, 'Atributos', [
                  PowerstatWidget(
                    label: 'Inteligência',
                    value: hero.intelligence,
                  ),
                  PowerstatWidget(label: 'Força', value: hero.strength),
                  PowerstatWidget(label: 'Velocidade', value: hero.speed),
                  PowerstatWidget(
                    label: 'Durabilidade',
                    value: hero.durability,
                  ),
                  PowerstatWidget(label: 'Poder', value: hero.power),
                  PowerstatWidget(label: 'Combate', value: hero.combat),
                ]),
                _section(context, 'Aparência', [
                  _detail('Gênero', hero.gender),
                  _detail('Raça', hero.race ?? 'Não informada'),
                  _detail('Altura', hero.height.join(' / ')),
                  _detail('Peso', hero.weight.join(' / ')),
                  _detail('Olhos', hero.eyeColor),
                  _detail('Cabelo', hero.hairColor),
                ]),
                _section(context, 'Biografia', [
                  _detail('Nome completo', hero.fullName),
                  _detail('Alter egos', hero.alterEgos),
                  _detail('Apelidos', hero.aliases.join(', ')),
                  _detail('Local de nascimento', hero.placeOfBirth),
                  _detail('Primeira aparição', hero.firstAppearance),
                  _detail('Editora', hero.publisher ?? 'Não informada'),
                  _detail('Alinhamento', hero.alignment),
                ]),
                _section(context, 'Trabalho', [
                  _detail('Ocupação', hero.occupation),
                  _detail('Base', hero.base),
                ]),
                _section(context, 'Conexões', [
                  _detail('Grupos', hero.groupAffiliation),
                  _detail('Parentes', hero.relatives),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: ${value.isEmpty ? 'Não informado' : value}'),
    );
  }
}
