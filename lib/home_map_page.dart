import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nexasafety/repositories/occurrence_repository.dart';
import 'package:nexasafety/models/occurrence.dart';
import 'package:nexasafety/models/api_occurrence.dart';
import 'package:nexasafety/core/services/api_client.dart';
import 'package:nexasafety/core/services/heatmap_service.dart';
import 'package:nexasafety/widgets/heatmap_filter_panel.dart';

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({super.key});

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  final MapController _mapController = MapController();
  final HeatmapService _heatmapService = HeatmapService();

  // São Paulo (fallback) - Av. Paulista
  LatLng _center = const LatLng(-23.55052, -46.633308);
  bool _locPermissionDenied = false;
  bool _isLoadingLocation = true;
  bool _isLoggedIn = false;

  // Heatmap state
  bool _showHeatmap = false;
  bool _showMarkers = true;
  bool _isLoadingHeatmap = false;
  List<ApiOccurrence> _occurrences = [];
  String? _filterType; // Filter by occurrence type

  // Marcadores: API occurrences (when logged in) + local repository fallback
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Add markers from API occurrences (when heatmap data is loaded)
    if (_occurrences.isNotEmpty) {
      for (final occurrence in _occurrences) {
        markers.add(
          Marker(
            point: LatLng(occurrence.latitude, occurrence.longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                // Navigate to detail page
                Navigator.of(context).pushNamed('/occurrence/${occurrence.id}');
              },
              child: _Pin(
                color: occurrence.getColorByType(),
                tooltip: _buildTooltip(occurrence),
              ),
            ),
          ),
        );
      }
    } else {
      // Fallback: Show fixed mock markers when no API data
      markers.addAll([
        Marker(
          point: const LatLng(-23.556, -46.662),
          width: 40,
          height: 40,
          child: const _Pin(color: Colors.orange, tooltip: 'Furto: bicicleta'),
        ),
        Marker(
          point: const LatLng(-23.554, -46.631),
          width: 40,
          height: 40,
          child: const _Pin(color: Colors.red, tooltip: 'Assalto: celular'),
        ),
        Marker(
          point: const LatLng(-23.548, -46.638),
          width: 40,
          height: 40,
          child: const _Pin(color: Colors.yellow, tooltip: 'Vandalismo: pichação'),
        ),
        Marker(
          point: const LatLng(-23.552, -46.644),
          width: 40,
          height: 40,
          child: const _Pin(color: Colors.blue, tooltip: 'Suspeita: atividade'),
        ),
      ]);

      // Add local repository occurrences
      final repo = OccurrenceRepository();
      for (final o in repo.all) {
        markers.add(
          Marker(
            point: LatLng(o.lat, o.lng),
            width: 40,
            height: 40,
            child: _Pin(
              color: _colorForType(o.type),
              tooltip: '${labelForType(o.type)}: ${o.description}',
            ),
          ),
        );
      }
    }

    return markers;
  }

  String _getTipoLabel(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'assalto':
        return 'Assalto';
      case 'roubo':
        return 'Roubo';
      case 'furto':
        return 'Furto';
      case 'vandalismo':
        return 'Vandalismo';
      case 'ameaca':
        return 'Ameaça';
      case 'agressao':
        return 'Agressão';
      case 'acidente_transito':
        return 'Acidente de Trânsito';
      case 'perturbacao':
        return 'Perturbação';
      case 'violencia_domestica':
        return 'Violência Doméstica';
      case 'trafico':
        return 'Tráfico';
      case 'homicidio':
        return 'Homicídio';
      case 'desaparecimento':
        return 'Desaparecimento';
      case 'incendio':
        return 'Incêndio';
      case 'outros':
        return 'Outros';
      default:
        return tipo;
    }
  }

  /// Build tooltip for marker with address info
  String _buildTooltip(ApiOccurrence occurrence) {
    final parts = <String>[];

    // Type and description
    parts.add('${_getTipoLabel(occurrence.tipo)}: ${occurrence.descricao}');

    // Add neighborhood if available
    if (occurrence.bairro != null && occurrence.bairro!.isNotEmpty) {
      parts.add('📍 ${occurrence.bairro}');
    }

    return parts.join('\n');
  }

  @override
  void initState() {
    super.initState();
    _ensureLocation();
    _checkAuth();
    _loadHeatmapData();
  }

  /// Load heatmap data from backend
  Future<void> _loadHeatmapData({bool forceRefresh = false}) async {
    if (!_isLoggedIn && !forceRefresh) {
      // Skip loading if not logged in
      return;
    }

    setState(() => _isLoadingHeatmap = true);

    try {
      // Fetch occurrences from backend
      final occurrences = await _heatmapService.fetchOccurrences(
        forceRefresh: forceRefresh,
      );

      // Apply filter if specified
      final filtered = _filterType != null
          ? occurrences.where((o) => o.tipo == _filterType).toList()
          : occurrences;

      setState(() {
        _occurrences = filtered;
        _isLoadingHeatmap = false;
      });
    } catch (e) {
      setState(() => _isLoadingHeatmap = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados do mapa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Toggle between markers and heatmap view
  void _toggleHeatmap() {
    setState(() {
      _showHeatmap = !_showHeatmap;
      if (_showHeatmap && _occurrences.isEmpty) {
        _loadHeatmapData();
      }
    });
  }

  /// Toggle markers visibility
  void _toggleMarkers() {
    setState(() => _showMarkers = !_showMarkers);
  }

  /// Show filter panel
  void _showFilterPanel() {
    if (_occurrences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carregue os dados do mapa primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final occurrenceCounts = _heatmapService.getOccurrenceCountByType(_occurrences);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HeatmapFilterPanel(
        occurrenceCounts: occurrenceCounts,
        selectedType: _filterType,
        onTypeSelected: (type) {
          _applyTypeFilter(type);
          Navigator.pop(context);
        },
        onClearFilters: () {
          _applyTypeFilter(null);
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Apply type filter and refresh heatmap
  void _applyTypeFilter(String? type) {
    setState(() {
      _filterType = type;
    });
    // Reload data with new filter
    _loadHeatmapData();
  }

  Future<void> _ensureLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Mantém fallback e informa usuário
        setState(() {
          _locPermissionDenied = true;
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _locPermissionDenied = true;
          _isLoadingLocation = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _center = LatLng(pos.latitude, pos.longitude);
        _isLoadingLocation = false;
      });

      // Anima mapa até localização atual
      _mapController.move(_center, 14);
    } catch (_) {
      setState(() {
        _isLoadingLocation = false;
        _locPermissionDenied = true;
      });
    }
  }

  void _recenter() {
    _mapController.move(_center, 14);
  }

  Future<void> _checkAuth() async {
    final token = await ApiClient().getToken();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  Future<void> _handleAuthAction() async {
    if (_isLoggedIn) {
      await ApiClient().clearToken();
      if (!mounted) return;
      setState(() => _isLoggedIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão encerrada.')),
      );
      // Redireciona para login após sair
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      await Navigator.of(context).pushNamed('/login');
      await _checkAuth();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NexaSafety'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nexasafety',
              ),
              // Marker layer - shows dense markers when heatmap is enabled
              if (_showMarkers)
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _MenuPanel(
                isLoggedIn: _isLoggedIn,
                onView: () => Navigator.of(context).pushNamed('/my'),
                onNew: () async {
                  final res = await Navigator.of(context).pushNamed('/new');
                  if (!mounted) return;
                  if (res == true) setState(() {});
                },
                onAuth: _handleAuthAction,
              ),
            ),
          ),
          if (_isLoadingLocation)
            const Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _InfoBanner(
                text: 'Obtendo localização...',
                background: Colors.black87,
              ),
            ),
          if (_locPermissionDenied && !_isLoadingLocation)
            const Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _InfoBanner(
                text:
                    'Permissão de localização negada ou desativada. Usando posição padrão.',
                background: Colors.orangeAccent,
              ),
            ),
          // Heatmap controls (top-right)
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                // Heatmap toggle button
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isLoggedIn ? _toggleHeatmap : null,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showHeatmap ? Icons.layers_clear : Icons.layers,
                            color: _isLoggedIn
                                ? (_showHeatmap ? Colors.red : Colors.blue)
                                : Colors.grey,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _showHeatmap ? 'Mapa' : 'Calor',
                            style: TextStyle(
                              fontSize: 10,
                              color: _isLoggedIn ? Colors.black87 : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Markers toggle button
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _toggleMarkers,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showMarkers
                                ? Icons.location_on
                                : Icons.location_off,
                            color: _showMarkers ? Colors.green : Colors.grey,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pinos',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter button
                if (_showHeatmap)
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 4,
                    child: Stack(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _showFilterPanel,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  color: _filterType != null
                                      ? Colors.purple
                                      : Colors.grey,
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Filtro',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Badge indicator when filter is active
                        if (_filterType != null)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.purple,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                // Loading indicator
                if (_isLoadingHeatmap)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recenter,
        tooltip: 'Centralizar',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  final Color color;
  final String tooltip;

  const _Pin({required this.color, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Icon(
        Icons.location_on,
        color: color,
        size: 34,
      ),
    );
  }
}

class _MenuPanel extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onView;
  final VoidCallback onNew;
  final VoidCallback onAuth;
  const _MenuPanel({
    required this.isLoggedIn,
    required this.onView,
    required this.onNew,
    required this.onAuth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuCircleButton(
            icon: Icons.receipt_long,
            tooltip: 'Ver ocorrências',
            onTap: onView,
          ),
          const SizedBox(height: 12),
          _MenuCircleButton(
            icon: Icons.add_location_alt_outlined,
            tooltip: 'Cadastrar ocorrência',
            onTap: onNew,
          ),
          const SizedBox(height: 12),
          _MenuCircleButton(
            icon: isLoggedIn ? Icons.logout : Icons.person_outline,
            tooltip: isLoggedIn ? 'Sair' : 'Entrar',
            onTap: onAuth,
          ),
        ],
      ),
    );
  }
}

class _MenuCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MenuCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.grey.shade700),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  final Color background;

  const _InfoBanner({required this.text, required this.background});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
