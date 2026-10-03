import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero.dart' as domain;
import '../widgets/powerstat_widget.dart';

class DailyContractPage extends StatefulWidget {
  const DailyContractPage({super.key});

  @override
  State<DailyContractPage> createState() => _DailyContractPageState();
}

class _DailyContractPageState extends State<DailyContractPage> {
  late final HeroRepository _repository;
  domain.Hero? _hero;
  String? _error;
  bool _loading = true;
  bool _recruiting = false;
  bool _inSquad = false;
  int _squadCount = 0;

  @override
  void initState() {
    super.initState();
    _repository = context.read<HeroRepository>();
    _loadHero();
  }

  Future<void> _loadHero() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final hero = await _repository.getDailyHero();
      final inSquad = await _repository.isHeroInSquad(hero.id);
      final squadCount = await _repository.getSquadCount();
      if (!mounted) return;
      setState(() {
        _hero = hero;
        _inSquad = inSquad;
        _squadCount = squadCount;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível carregar o contrato diário.';
        _loading = false;
      });
    }
  }

  Future<void> _recruitHero() async {
    final hero = _hero;
    if (hero == null || _recruiting || _inSquad) return;
    if (_squadCount >= 15) {
      _showMessage('O esquadrão já tem 15 agentes.');
      return;
    }

    setState(() => _recruiting = true);
    try {
      await _repository.recruitHero(hero.id);
      if (!mounted) return;
      setState(() {
        _inSquad = true;
        _squadCount++;
      });
      _showMessage('${hero.name} entrou para o esquadrão.');
    } on StateError catch (error) {
      if (!mounted) return;
      _showMessage(error.message.toString());
    } catch (_) {
      if (!mounted) return;
      _showMessage('Não foi possível recrutar este agente.');
    } finally {
      if (mounted) setState(() => _recruiting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contrato Diário')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  TextButton(
                    onPressed: _loadHero,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : _buildContract(context, _hero!),
    );
  }

  Widget _buildContract(BuildContext context, domain.Hero hero) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CachedNetworkImage(
                imageUrl: hero.imageLg,
                height: 280,
                fit: BoxFit.contain,
                placeholder: (_, _) => const SizedBox(
                  height: 280,
                  child: Icon(Icons.image, size: 72),
                ),
                errorWidget: (_, _, _) => const SizedBox(
                  height: 280,
                  child: Icon(Icons.image_not_supported, size: 72),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hero.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Esquadrão: $_squadCount/15', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _recruiting || _inSquad ? null : _recruitHero,
                child: Text(
                  _inSquad
                      ? 'Já está no Esquadrão'
                      : 'Recrutar para o Esquadrão',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
