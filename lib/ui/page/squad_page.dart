import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero.dart' as domain;
import '../widgets/squad_agent_widget.dart';
import 'squad_hero_details_page.dart';

class SquadPage extends StatefulWidget {
  const SquadPage({super.key});

  @override
  State<SquadPage> createState() => _SquadPageState();
}

class _SquadPageState extends State<SquadPage> {
  late final HeroRepository _repository;
  List<domain.Hero> _squad = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = context.read<HeroRepository>();
    _loadSquad();
  }

  Future<void> _loadSquad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final squad = await _repository.getSquad();
      if (!mounted) return;
      setState(() {
        _squad = squad;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível carregar o esquadrão.';
        _loading = false;
      });
    }
  }

  Future<void> _openHero(domain.Hero hero) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => SquadHeroDetailsPage(hero: hero)),
    );
    if (mounted) await _loadSquad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Esquadrão')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  TextButton(
                    onPressed: _loadSquad,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : _squad.isEmpty
          ? const Center(child: Text('Nenhum agente no esquadrão.'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Agentes: ${_squad.length}/15'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _squad.length,
                    itemBuilder: (context, index) {
                      final hero = _squad[index];
                      return SquadAgentWidget(
                        hero: hero,
                        onTap: () => _openHero(hero),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
