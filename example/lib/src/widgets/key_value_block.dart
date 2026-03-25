import 'package:flutter/material.dart';

class KeyValueBlock extends StatelessWidget {
  const KeyValueBlock({super.key, required this.title, required this.data});

  final String title;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          ...data.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${entry.key}: ${entry.value}'),
            ),
          ),
        ],
      ),
    );
  }
}
