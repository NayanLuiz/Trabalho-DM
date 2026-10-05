import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero.dart' as domain;

enum _MissionStage { loading, insufficient, round, result, error }

class MissionFirstRoundPage extends StatefulWidget {
  const MissionFirstRoundPage({super.key});

  @override
  State<MissionFirstRoundPage> createState() => _MissionFirstRoundPageState();
}

class _MissionFirstRoundPageState extends State<MissionFirstRoundPage> {
  static const _attributes = <String>[
    'intelligence',
    'strength',
    'speed',
    'durability',
    'power',
    'combat',
  ];

  final Random _random = Random();
  late final HeroRepository _repository;
  _MissionStage _stage = _MissionStage.loading;
  List<domain.Hero> _squad = [];
  final Set<int> _usedHeroIds = {};
  int _totalRounds = 0;
  domain.Hero? _enemy;
  domain.Hero? _selectedHero;
  String? _attribute;
  String? _result;
  String? _error;
  int? _heroValue;
  int? _enemyValue;

  @override
  void initState() {
    super.initState();
    _repository = context.read<HeroRepository>();
    _loadMission();
  }

  Future<void> _loadMission() async {
    setState(() {
      _stage = _MissionStage.loading;
      _error = null;
    });
    try {
      final squad = await _repository.getSquad();
      if (!mounted) return;
      if (squad.length < 5) {
        setState(() {
          _squad = squad;
          _stage = _MissionStage.insufficient;
        });
        return;
      }

      final squadIds = squad.map((hero) => hero.id).toSet();
      final catalog = await _repository.getHeroes(page: 1, limit: 1000);
      final enemies = catalog
          .where((hero) => !squadIds.contains(hero.id))
          .toList();
      if (enemies.isEmpty) {
        throw StateError('Nenhum inimigo disponível fora do esquadrão.');
      }
      if (!mounted) return;
      setState(() {
        _squad = squad;
        _totalRounds = 3 + _random.nextInt(3);
        _enemy = enemies[_random.nextInt(enemies.length)];
        _attribute = _attributes[_random.nextInt(_attributes.length)];
        _usedHeroIds.clear();
        _selectedHero = null;
        _result = null;
        _heroValue = null;
        _enemyValue = null;
        _stage = _MissionStage.round;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is StateError
            ? error.message.toString()
            : 'Não foi possível iniciar a missão.';
        _stage = _MissionStage.error;
      });
    }
  }

  int _powerStat(domain.Hero hero, String attribute) => switch (attribute) {
    'intelligence' => hero.intelligence,
    'strength' => hero.strength,
    'speed' => hero.speed,
    'durability' => hero.durability,
    'power' => hero.power,
    'combat' => hero.combat,
    _ => throw ArgumentError.value(attribute, 'attribute'),
  };

  void _chooseHero(domain.Hero hero) {
    if (_stage != _MissionStage.round || _usedHeroIds.contains(hero.id)) return;
    final heroValue = _powerStat(hero, _attribute!);
    final enemyValue = _powerStat(_enemy!, _attribute!);
    setState(() {
      _usedHeroIds.add(hero.id);
      _selectedHero = hero;
      _heroValue = heroValue;
      _enemyValue = enemyValue;
      _result = heroValue > enemyValue
          ? 'Vitória!'
          : heroValue < enemyValue
          ? 'Derrota!'
          : 'Empate!';
      _stage = _MissionStage.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Missões')),
      body: switch (_stage) {
        _MissionStage.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        _MissionStage.insufficient => const Center(
          child: Text('Você precisa de pelo menos 5 agentes.'),
        ),
        _MissionStage.error => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              TextButton(
                onPressed: _loadMission,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        _MissionStage.round || _MissionStage.result => _buildRound(context),
      },
    );
  }

  Widget _buildRound(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ROUND 1 / $_totalRounds',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Atributo: ${_attribute!.toUpperCase()}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              CachedNetworkImage(
                imageUrl: _enemy!.imageMd,
                height: 180,
                fit: BoxFit.contain,
                placeholder: (_, _) => const Icon(Icons.person, size: 96),
                errorWidget: (_, _, _) =>
                    const Icon(Icons.person_off, size: 96),
              ),
              Text(
                _enemy!.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Text('Escolha seu agente'),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _squad.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final hero = _squad[index];
                  final used = _usedHeroIds.contains(hero.id);
                  return Card(
                    child: InkWell(
                      key: ValueKey('mission-agent-${hero.id}'),
                      onTap: _stage == _MissionStage.round && !used
                          ? () => _chooseHero(hero)
                          : null,
                      child: Opacity(
                        opacity: used ? 0.4 : 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: hero.imageSm,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                placeholder: (_, _) =>
                                    const Icon(Icons.person, size: 64),
                                errorWidget: (_, _, _) =>
                                    const Icon(Icons.person_off, size: 64),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hero.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_stage == _MissionStage.result) ...[
                const SizedBox(height: 16),
                Text(
                  _result!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('${_selectedHero!.name}: $_heroValue'),
                Text('Inimigo: $_enemyValue'),
                const SizedBox(height: 8),
                const Text('Próximos rounds na próxima fase.'),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Encerrar missão'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
