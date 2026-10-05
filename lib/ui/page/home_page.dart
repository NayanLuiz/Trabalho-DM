import 'package:flutter/material.dart';

import 'daily_contract_page.dart';
import 'heroes_list_page.dart';
import 'mission_first_round_page.dart';
import 'squad_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agência de Heróis')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.shield, size: 72),
                  const SizedBox(height: 16),
                  Text(
                    'Escolha sua missão',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const HeroesListPage(),
                      ),
                    ),
                    icon: const Icon(Icons.people),
                    label: const Text('AGENTES'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const DailyContractPage(),
                      ),
                    ),
                    icon: const Icon(Icons.today),
                    label: const Text('CONTRATO DIÁRIO'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const SquadPage(),
                      ),
                    ),
                    icon: const Icon(Icons.groups),
                    label: const Text('MEU ESQUADRÃO'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const MissionFirstRoundPage(),
                      ),
                    ),
                    icon: const Icon(Icons.flag),
                    label: const Text('MISSÕES'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
