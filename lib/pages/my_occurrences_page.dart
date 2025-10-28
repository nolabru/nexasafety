import 'package:flutter/material.dart';
import 'package:nexasafety/repositories/occurrence_repository.dart';
import 'package:nexasafety/models/occurrence.dart';
import 'package:nexasafety/core/services/occurrence_service.dart';
import 'package:nexasafety/core/services/api_client.dart';
import 'package:nexasafety/models/api_occurrence.dart';

class MyOccurrencesPage extends StatefulWidget {
  const MyOccurrencesPage({super.key});

  @override
  State<MyOccurrencesPage> createState() => _MyOccurrencesPageState();
}

class _MyOccurrencesPageState extends State<MyOccurrencesPage> {
  bool _useApi = false;
  bool _loading = true;
  List<ApiOccurrence> _apiItems = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    try {
      final token = await ApiClient().getToken();
      if (token != null && token.isNotEmpty) {
        final items = await OccurrenceService().getMyOccurrences();
        if (!mounted) return;
        setState(() {
          _useApi = true;
          _apiItems = items;
          _loading = false;
        });
        return;
      }
    } catch (_) {
      // fallback para local
    }
    if (!mounted) return;
    setState(() {
      _useApi = false;
      _loading = false;
    });
  }

  Color _colorForLocalType(String t) {
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

  String _labelForApiType(String tipo) {
    switch (tipo) {
      case 'ROUBO':
        return 'Roubo';
      case 'FURTO':
        return 'Furto';
      case 'VANDALISMO':
        return 'Vandalismo';
      case 'ASSALTO':
        return 'Assalto';
      case 'AMEACA':
        return 'Ameaça';
      case 'OUTROS':
      default:
        return 'Outros';
    }
  }

  Color _colorForApiType(String tipo) {
    switch (tipo) {
      case 'ROUBO':
        return Colors.red;
      case 'FURTO':
        return Colors.orange;
      case 'VANDALISMO':
        return Colors.purple;
      case 'ASSALTO':
        return Colors.deepOrange;
      case 'AMEACA':
        return Colors.amber;
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

  /// Show dialog with local occurrence details
  void _showLocalOccurrenceDialog(BuildContext context, Occurrence occurrence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: _colorForLocalType(occurrence.type),
            ),
            const SizedBox(width: 8),
            Text(labelForType(occurrence.type)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Descrição:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(occurrence.description),
              const SizedBox(height: 16),
              const Text(
                'Localização:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Lat: ${occurrence.lat.toStringAsFixed(6)}\nLng: ${occurrence.lng.toStringAsFixed(6)}',
              ),
              const SizedBox(height: 16),
              const Text(
                'Criado:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(_relativeTime(occurrence.createdAt)),
              const SizedBox(height: 16),
              const Text(
                'Status:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text('Salvo localmente (não sincronizado)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = OccurrenceRepository();
    final localItems = repo.all;

    final hasItems = _useApi ? _apiItems.isNotEmpty : localItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Ocorrências'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !hasItems
              ? _EmptyState(onNew: () => Navigator.of(context).pushNamed('/new'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemBuilder: (_, i) {
                      if (_useApi) {
                        final o = _apiItems[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _colorForApiType(o.tipo),
                            child:
                                const Icon(Icons.location_on, color: Colors.white),
                          ),
                          title: Text(_labelForApiType(o.tipo)),
                          subtitle: Text(
                            '${o.descricao}\n${_relativeTime(o.createdAt)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to detail page with occurrence ID
                            Navigator.of(context).pushNamed('/occurrence/${o.id}');
                          },
                        );
                      } else {
                        final o = localItems[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _colorForLocalType(o.type),
                            child:
                                const Icon(Icons.location_on, color: Colors.white),
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
                            // Local occurrences don't have backend IDs yet
                            // Show detailed info in a dialog instead
                            _showLocalOccurrenceDialog(context, o);
                          },
                        );
                      }
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _useApi ? _apiItems.length : localItems.length,
                  ),
                ),
      floatingActionButton: hasItems
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed('/new'),
              icon: const Icon(Icons.add),
              label: const Text('Nova'),
            )
          : null,
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
