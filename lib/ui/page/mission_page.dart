import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero.dart' as domain;

enum _MissionStage { loading, insufficient, round, result, finished, error }

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  static const _attributes = <String>[
    'intelligence',
    'strength',
    'speed',
    'durability',
    'power',
    'combat',
  ];
  static const _attributeNames = <String, String>{
    'intelligence': 'INTELIGÊNCIA',
    'strength': 'FORÇA',
    'speed': 'VELOCIDADE',
    'durability': 'DURABILIDADE',
    'power': 'PODER',
    'combat': 'COMBATE',
  };

  final Random _random = Random();
  late final HeroRepository _repository;
  _MissionStage _stage = _MissionStage.loading;
  List<domain.Hero> _squad = [];
  List<domain.Hero> _enemies = [];
  final Set<int> _usedHeroIds = {};
  final List<domain.Hero> _winners = [];
  int _round = 1;
  int _totalRounds = 0;
  int _victories = 0;
  int _defeats = 0;
  int _draws = 0;
  late domain.Hero _enemy;
  late String _attribute;
  domain.Hero? _selectedHero;
  int? _heroValue;
  int? _enemyValue;
  String? _roundResult;
  bool _finishing = false;
  String? _error;

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
        _enemies = enemies;
        _totalRounds = 3 + _random.nextInt(3);
        _round = 1;
        _victories = 0;
        _defeats = 0;
        _draws = 0;
        _usedHeroIds.clear();
        _winners.clear();
        _prepareRound();
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

  void _prepareRound() {
    _enemy = _enemies[_random.nextInt(_enemies.length)];
    _attribute = _attributes[_random.nextInt(_attributes.length)];
    _selectedHero = null;
    _heroValue = null;
    _enemyValue = null;
    _roundResult = null;
    _stage = _MissionStage.round;
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

  domain.Hero _withBonus(domain.Hero hero, String attribute) {
    final value = _powerStat(hero, attribute) + 1;
    return switch (attribute) {
      'intelligence' => hero.copyWith(intelligence: value),
      'strength' => hero.copyWith(strength: value),
      'speed' => hero.copyWith(speed: value),
      'durability' => hero.copyWith(durability: value),
      'power' => hero.copyWith(power: value),
      'combat' => hero.copyWith(combat: value),
      _ => throw ArgumentError.value(attribute, 'attribute'),
    };
  }

  void _chooseHero(domain.Hero hero) {
    if (_stage != _MissionStage.round || _usedHeroIds.contains(hero.id)) return;
    final heroValue = _powerStat(hero, _attribute);
    final enemyValue = _powerStat(_enemy, _attribute);
    setState(() {
      _usedHeroIds.add(hero.id);
      _selectedHero = hero;
      _heroValue = heroValue;
      _enemyValue = enemyValue;
      if (heroValue > enemyValue) {
        _victories++;
        _winners.add(hero);
        _roundResult = 'Vitória!';
      } else if (heroValue < enemyValue) {
        _defeats++;
        _roundResult = 'Derrota!';
      } else {
        _draws++;
        _roundResult = 'Empate!';
      }
      _stage = _MissionStage.result;
    });
  }

  Future<void> _advance() async {
    if (_stage != _MissionStage.result || _finishing) return;
    if (_round < _totalRounds) {
      setState(() {
        _round++;
        _prepareRound();
      });
      return;
    }
    setState(() => _finishing = true);
    domain.Hero? rewardedHero;
    String? rewardedAttribute;
    try {
      if (_victories > _totalRounds / 2) {
        final winner = _winners[_random.nextInt(_winners.length)];
        rewardedAttribute = _attributes[_random.nextInt(_attributes.length)];
        rewardedHero = _withBonus(winner, rewardedAttribute);
        await _repository.updateHero(rewardedHero);
      }
      if (!mounted) return;
      setState(() {
        _finishing = false;
        _stage = _MissionStage.finished;
      });
      _showFinalDialog(rewardedHero, rewardedAttribute);
    } catch (_) {
      if (!mounted) return;
      setState(() => _finishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o bônus. Tente novamente.'),
        ),
      );
    }
  }

  void _showFinalDialog(domain.Hero? rewardedHero, String? rewardedAttribute) {
    final success = rewardedHero != null;
    final defeat = _defeats > _totalRounds / 2;
    AwesomeDialog(
      context: context,
      dialogType: success
          ? DialogType.success
          : defeat
          ? DialogType.error
          : DialogType.warning,
      customHeader: Icon(
        success
            ? Icons.check_circle
            : defeat
            ? Icons.cancel
            : Icons.warning_amber,
        color: success
            ? Colors.green
            : defeat
            ? Colors.red
            : Colors.orange,
        size: 72,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            success
                ? 'Missão Cumprida!'
                : defeat
                ? 'Operação Fracassada!'
                : 'Missão Empatada!',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (rewardedHero != null)
            CachedNetworkImage(
              imageUrl: rewardedHero.imageSm,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const Icon(Icons.person, size: 72),
            )
          else if (defeat)
            CachedNetworkImage(
              imageUrl: _enemy.imageSm,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) =>
                  const Icon(Icons.sentiment_very_dissatisfied, size: 72),
            )
          else
            const Icon(Icons.handshake, size: 72),
          const SizedBox(height: 8),
          Text(
            success
                ? '${rewardedHero.name}: +1 em ${_attributeNames[rewardedAttribute]}.'
                : defeat
                ? 'Seu esquadrão perdeu a operação.'
                : 'Nenhum bônus nesta missão.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      btnOkText: 'Concluir',
      btnOkOnPress: () {},
    ).show();
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
        _MissionStage.finished => _buildSummary(context),
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
                'ROUND $_round / $_totalRounds',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Atributo: ${_attributeNames[_attribute]}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              CachedNetworkImage(
                imageUrl: _enemy.imageMd,
                height: 180,
                fit: BoxFit.contain,
                placeholder: (_, _) => const Icon(Icons.person, size: 96),
                errorWidget: (_, _, _) =>
                    const Icon(Icons.person_off, size: 96),
              ),
              Text(
                _enemy.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (_stage == _MissionStage.round) ...[
                const Text('Escolha seu agente'),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _squad.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final hero = _squad[index];
                    final used = _usedHeroIds.contains(hero.id);
                    return Card(
                      child: InkWell(
                        key: ValueKey('mission-hero-${hero.id}'),
                        onTap: used ? null : () => _chooseHero(hero),
                        child: Opacity(
                          opacity: used ? 0.4 : 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: hero.imageSm,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) =>
                                      const Icon(Icons.person, size: 48),
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
              ] else ...[
                Text(
                  _roundResult!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${_selectedHero!.name}: $_heroValue × ${_enemy.name}: $_enemyValue',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _finishing ? null : _advance,
                  child: Text(
                    _round < _totalRounds ? 'Próximo round' : 'Ver resultado',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Vitórias: $_victories   Derrotas: $_defeats   Empates: $_draws',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Resumo da missão',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text('Vitórias: $_victories'),
          Text('Derrotas: $_defeats'),
          Text('Empates: $_draws'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMission,
            child: const Text('Nova missão'),
          ),
        ],
      ),
    );
  }
}
