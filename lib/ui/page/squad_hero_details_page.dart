import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero.dart' as domain;
import 'hero_details_page.dart';

class SquadHeroDetailsPage extends StatefulWidget {
  final domain.Hero hero;

  const SquadHeroDetailsPage({super.key, required this.hero});

  @override
  State<SquadHeroDetailsPage> createState() => _SquadHeroDetailsPageState();
}

class _SquadHeroDetailsPageState extends State<SquadHeroDetailsPage> {
  late final HeroRepository _repository;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _repository = context.read<HeroRepository>();
  }

  Future<void> _confirmDismiss() async {
    if (_dismissing) return;
    var confirmed = false;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      title: 'Dispensar agente?',
      desc: 'Deseja dispensar este agente?',
      btnCancelText: 'Cancelar',
      btnOkText: 'Dispensar',
      btnCancelOnPress: () {},
      btnOkOnPress: () => confirmed = true,
    ).show();

    if (!mounted || !confirmed) return;
    setState(() => _dismissing = true);
    try {
      await _repository.dismissHero(widget.hero.id);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _dismissing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível dispensar o agente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeroDetailsPage(
      hero: widget.hero,
      bottomAction: ElevatedButton(
        onPressed: _dismissing ? null : _confirmDismiss,
        child: const Text('DISPENSAR DO ESQUADRÃO'),
      ),
    );
  }
}
