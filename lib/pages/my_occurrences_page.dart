import 'package:flutter/material.dart';
import 'package:nexasafety/repositories/occurrence_repository.dart';
import 'package:nexasafety/models/occurrence.dart';

class MyOccurrencesPage extends StatefulWidget {
  const MyOccurrencesPage({super.key});

  @override
  State<MyOccurrencesPage> createState() => _MyOccurrencesPageState();
}

class _MyOccurrencesPageState extends State<MyOccurrencesPage> {
  Color _colorForType(String t) {
    switch (t) {
      case 'assalto':
        return Colors.red;
      case 'furto':
        return Colors.orange;
      case 'vandalismo':
        return Colors.yellow;
      case 'suspeita':
        return Colors.blue;
      case 'concluido':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'Há ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    return 'Há ${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final repo = OccurrenceRepository();
    final items = repo.all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Ocorrências'),
      ),
      body: items.isEmpty
          ? _EmptyState(onNew: () => Navigator.of(context).pushNamed('/new'))
          : RefreshIndicator(
              onRefresh: () async {
                // Mock: apenas aguarda e recarrega a lista local
                await Future.delayed(const Duration(milliseconds: 500));
                if (!mounted) return;
                setState(() {});
              },
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemBuilder: (_, i) {
                  final o = items[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _colorForType(o.type),
                      child: const Icon(Icons.location_on, color: Colors.white),
                    ),
                    title: Text(labelForType(o.type)),
                    subtitle: Text(
                      '${o.description}\n${_relativeTime(o.createdAt)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Poderia abrir detalhes; por enquanto apenas snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Detalhes (WIP).')),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: items.length,
              ),
            ),
      floatingActionButton: items.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed('/new'),
              icon: const Icon(Icons.add),
              label: const Text('Nova'),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onNew;
  const _EmptyState({required this.onNew});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: color),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma ocorrência registrada ainda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registre sua primeira ocorrência para que ela apareça aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add),
              label: const Text('Registrar Ocorrência'),
            ),
          ],
        ),
      ),
    );
  }
}
