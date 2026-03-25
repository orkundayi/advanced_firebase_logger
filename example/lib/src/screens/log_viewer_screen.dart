import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../example_constants.dart';
import '../map_utils.dart';
import '../widgets/centered_message.dart';
import '../widgets/key_value_block.dart';

class LogViewerScreen extends StatelessWidget {
  const LogViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(logCollectionName)
          .orderBy('timestamp', descending: true)
          .limit(40)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CenteredMessage(
            title: 'Could not load logs',
            message: '${snapshot.error}',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs =
            snapshot.data?.docs ??
            const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        if (docs.isEmpty) {
          return const CenteredMessage(
            title: 'No logs yet',
            message:
                'Send a few events from the Write Logs screen and they will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final level = data['level']?.toString() ?? 'UNKNOWN';
            final message = data['message']?.toString() ?? 'No message';
            final tag = data['tag']?.toString();
            final clientTimestamp = data['clientTimestamp']?.toString() ?? '-';
            final contextData = mapValue(data['context']);
            final extras = mapValue(data['extras']);
            final errorData = mapValue(data['error']);

            return Card(
              child: ExpansionTile(
                leading: CircleAvatar(child: Text(level.characters.first)),
                title: Text(message),
                subtitle: Text('$level${tag != null ? '  •  $tag' : ''}'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Client time: $clientTimestamp'),
                  const SizedBox(height: 8),
                  if (contextData.isNotEmpty)
                    KeyValueBlock(title: 'Context', data: contextData),
                  if (extras.isNotEmpty)
                    KeyValueBlock(title: 'Extras', data: extras),
                  if (errorData.isNotEmpty)
                    KeyValueBlock(title: 'Error', data: errorData),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
