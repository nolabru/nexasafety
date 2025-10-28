import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexasafety/models/api_occurrence.dart';
import 'package:nexasafety/core/services/occurrence_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Detailed view of a single occurrence
/// Shows media gallery, status timeline, location, and full description
class OccurrenceDetailPage extends StatefulWidget {
  final String occurrenceId;

  const OccurrenceDetailPage({
    super.key,
    required this.occurrenceId,
  });

  @override
  State<OccurrenceDetailPage> createState() => _OccurrenceDetailPageState();
}

class _OccurrenceDetailPageState extends State<OccurrenceDetailPage> {
  final _occurrenceService = OccurrenceService();

  ApiOccurrence? _occurrence;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadOccurrence();
  }

  Future<void> _loadOccurrence() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final occurrence = await _occurrenceService.getById(widget.occurrenceId);
      setState(() {
        _occurrence = occurrence;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar ocorrência: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Ocorrência'),
        actions: [
          if (_occurrence != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compartilhar (em breve)')),
                );
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOccurrence,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_occurrence == null) {
      return const Center(
        child: Text('Ocorrência não encontrada'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOccurrence,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (_occurrence!.media != null && _occurrence!.media!.isNotEmpty)
            _buildMediaGallery(),
          if (_occurrence!.media != null && _occurrence!.media!.isNotEmpty)
            const SizedBox(height: 16),
          _buildDescriptionCard(),
          const SizedBox(height: 16),
          _buildLocationCard(),
          const SizedBox(height: 16),
          _buildStatusTimeline(),
          const SizedBox(height: 16),
          _buildMetadataCard(),
        ],
      ),
    );
  }

  /// Header with type, status badge, and timestamp
  Widget _buildHeader() {
    final occurrence = _occurrence!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: occurrence.getColorByType().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    occurrence.getIconByType(),
                    color: occurrence.getColorByType(),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTipoLabel(occurrence.tipo),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(occurrence.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(occurrence.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Media gallery with carousel and thumbnails
  Widget _buildMediaGallery() {
    final media = _occurrence!.media!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main image viewer
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: media[_selectedMediaIndex].url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          // Thumbnail strip
          if (media.length > 1)
            Container(
              height: 80,
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: media.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedMediaIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedMediaIndex = index);
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: media[index].url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Description card
  Widget _buildDescriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _occurrence!.descricao,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Location card with mini map
  Widget _buildLocationCard() {
    final occurrence = _occurrence!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Localização',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Mini map
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(occurrence.latitude, occurrence.longitude),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.nexasafety',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(occurrence.latitude, occurrence.longitude),
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          size: 40,
                          color: occurrence.getColorByType(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Address information
            if (occurrence.endereco != null)
              _buildLocationRow(Icons.home, occurrence.endereco!),
            if (occurrence.bairro != null)
              _buildLocationRow(Icons.location_city, occurrence.bairro!),
            if (occurrence.cidade != null && occurrence.estado != null)
              _buildLocationRow(
                Icons.place,
                '${occurrence.cidade}, ${occurrence.estado}',
              ),
            _buildLocationRow(
              Icons.pin_drop,
              '${occurrence.latitude.toStringAsFixed(6)}, ${occurrence.longitude.toStringAsFixed(6)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Status timeline
  Widget _buildStatusTimeline() {
    final occurrence = _occurrence!;
    final statuses = [
      _TimelineItem(
        status: 'PENDING',
        label: 'Recebida',
        date: occurrence.createdAt,
        isCompleted: true,
      ),
      _TimelineItem(
        status: 'IN_PROGRESS',
        label: 'Em análise',
        date: occurrence.status == 'IN_PROGRESS' ||
                occurrence.status == 'RESOLVED' ||
                occurrence.status == 'REJECTED'
            ? occurrence.updatedAt
            : null,
        isCompleted: occurrence.status == 'IN_PROGRESS' ||
            occurrence.status == 'RESOLVED' ||
            occurrence.status == 'REJECTED',
      ),
      _TimelineItem(
        status: occurrence.status == 'REJECTED' ? 'REJECTED' : 'RESOLVED',
        label: occurrence.status == 'REJECTED' ? 'Rejeitada' : 'Concluída',
        date: occurrence.resolvedAt,
        isCompleted: occurrence.status == 'RESOLVED' || occurrence.status == 'REJECTED',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...statuses.map((item) => _buildTimelineStep(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(_TimelineItem item) {
    final isLast = item.status == 'RESOLVED' || item.status == 'REJECTED';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isCompleted ? Colors.green : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isCompleted ? Colors.green.shade700 : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: item.isCompleted ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: item.isCompleted ? FontWeight.w600 : FontWeight.normal,
                  color: item.isCompleted ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
              if (item.date != null)
                Text(
                  _formatDateTime(item.date!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  /// Metadata card (user info, visibility)
  Widget _buildMetadataCard() {
    final occurrence = _occurrence!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Informações',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ID', occurrence.id),
            _buildInfoRow(
              'Visibilidade',
              occurrence.isPublic ? 'Pública' : 'Privada',
            ),
            if (occurrence.usuario != null)
              _buildInfoRow('Reportado por', occurrence.usuario!.nome),
            if (occurrence.updatedAt != null)
              _buildInfoRow(
                'Última atualização',
                _formatDateTime(occurrence.updatedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        label = 'Pendente';
        break;
      case 'IN_PROGRESS':
        color = Colors.blue;
        label = 'Em análise';
        break;
      case 'RESOLVED':
        color = Colors.green;
        label = 'Concluída';
        break;
      case 'REJECTED':
        color = Colors.red;
        label = 'Rejeitada';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'ASSALTO':
        return 'Assalto';
      case 'ROUBO':
        return 'Roubo';
      case 'FURTO':
        return 'Furto';
      case 'VANDALISMO':
        return 'Vandalismo';
      case 'AMEACA':
        return 'Ameaça';
      case 'OUTROS':
        return 'Outros';
      default:
        return tipo;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inHours < 1) {
      return 'Há ${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return 'Há ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays}d';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _TimelineItem {
  final String status;
  final String label;
  final DateTime? date;
  final bool isCompleted;

  _TimelineItem({
    required this.status,
    required this.label,
    required this.date,
    required this.isCompleted,
  });
}
