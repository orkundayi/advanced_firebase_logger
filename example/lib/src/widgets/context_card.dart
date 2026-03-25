import 'package:flutter/material.dart';

class ContextCard extends StatelessWidget {
  const ContextCard({super.key, required this.title, required this.data});

  final String title;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              data.entries
                  .map((entry) => '${entry.key}: ${entry.value}')
                  .join('\n'),
            ),
          ],
        ),
      ),
    );
  }
}
