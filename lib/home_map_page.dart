import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nexasafety/repositories/occurrence_repository.dart';
import 'package:nexasafety/models/occurrence.dart';
import 'package:nexasafety/core/services/api_client.dart';

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({super.key});

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  final MapController _mapController = MapController();

  // São Paulo (fallback) - Av. Paulista
  LatLng _center = const LatLng(-23.55052, -46.633308);
  bool _locPermissionDenied = false;
  bool _isLoadingLocation = true;
  bool _isLoggedIn = false;

  // Marcadores: fixa alguns mocks e inclui os criados pelo usuário (repositório)
  List<Marker> _buildMarkers() {
    final fixed = <Marker>[
      Marker(
        point: const LatLng(-23.556, -46.662), // furto
        width: 40,
        height: 40,
        child: const _Pin(color: Colors.orange, tooltip: 'Furto: bicicleta'),
      ),
      Marker(
        point: const LatLng(-23.554, -46.631), // assalto
        width: 40,
        height: 40,
        child: const _Pin(color: Colors.red, tooltip: 'Assalto: celular'),
      ),
      Marker(
        point: const LatLng(-23.548, -46.638), // vandalismo
        width: 40,
        height: 40,
        child: const _Pin(color: Colors.yellow, tooltip: 'Vandalismo: pichação'),
      ),
      Marker(
        point: const LatLng(-23.552, -46.644), // outros
        width: 40,
        height: 40,
        child: const _Pin(color: Colors.blue, tooltip: 'Suspeita: atividade'),
      ),
      Marker(
        point: const LatLng(-23.545, -46.633), // concluído
        width: 40,
        height: 40,
        child: const _Pin(color: Colors.green, tooltip: 'Concluído'),
      ),
    ];

    final repo = OccurrenceRepository();
    final dynamicMarkers = repo.all
        .map(
          (o) => Marker(
            point: LatLng(o.lat, o.lng),
            width: 40,
            height: 40,
            child: _Pin(
              color: _colorForType(o.type),
              tooltip: '${labelForType(o.type)}: ${o.description}',
            ),
          ),
        )
        .toList();

    return [...fixed, ...dynamicMarkers];
  }

  @override
  void initState() {
    super.initState();
    _ensureLocation();
    _checkAuth();
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
