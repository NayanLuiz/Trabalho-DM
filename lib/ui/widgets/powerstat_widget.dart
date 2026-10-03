import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

class PowerstatWidget extends StatelessWidget {
  final String label;
  final int value;

  const PowerstatWidget({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(label), Text('$value')],
          ),
          const SizedBox(height: 4),
          PrimerProgressBar(
            segments: [
              Segment(
                value: value.clamp(0, 100),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
            maxTotalValue: 100,
            showLegend: false,
          ),
        ],
      ),
    );
  }
}
