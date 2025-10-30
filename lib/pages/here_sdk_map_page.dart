import 'dart:async';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:nexasafety/core/services/heatmap_service.dart';
import 'package:nexasafety/core/services/api_client.dart'
    show UnauthorizedException, ApiException, ApiClient;
import 'package:nexasafety/core/services/occurrence_service.dart';

class HereSdkMapPage extends StatefulWidget {
  const HereSdkMapPage({super.key});

  @override
  State<HereSdkMapPage> createState() => _HereSdkMapPageState();
}

class _HereSdkMapPageState extends State<HereSdkMapPage> {
  HereMapController? _controller;

  // Heatmap state
  final _heatmapService = HeatmapService();
  final List<MapPolygon> _heatPolygons = [];
  MapIdleListener? _idleListener;
  Timer? _debounce;
  String? _statusMessage;
  int? _lastPointsCount;
  final _occurrenceService = OccurrenceService();
  
  // Cache to prevent unnecessary requests
  String? _lastBoundsKey;
  bool _isLoadingHeatmap = false;

  @override
  void initState() {
    super.initState();
    SdkContext.init(IsolateOrigin.main);
  }

  void _onMapCreated(HereMapController controller) {
    _controller = controller;

    // Carrega o mapa e centraliza após sucesso.
    controller.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (error) {
      if (error != null) {
        debugPrint('HERE Map scene load failed: $error');
        return;
      }
      final target = GeoCoordinates(-23.55052, -46.633308); // São Paulo
      final distance = MapMeasure(MapMeasureKind.distanceInMeters, 8000);
      controller.camera.lookAtPointWithMeasure(target, distance);

      // Attach map idle listener and draw initial heatmap.
      _attachIdleListener(controller);
      _refreshHeatmap();
    });
  }

  @override
  void dispose() {
    // Remove listeners and overlays
    try {
      if (_idleListener != null && _controller != null) {
        _controller!.hereMapControllerCore.removeMapIdleListener(
          _idleListener!,
        );
      }
    } catch (_) {}
    _debounce?.cancel();
    _clearHeatPolygons();
    super.dispose();
  }

  void _attachIdleListener(HereMapController controller) {
    try {
      _idleListener = MapIdleListener(
        () {
          // on busy: do nothing
        },
        () {
          // on idle: debounce updates
          _scheduleHeatmapUpdate();
        },
      );
      controller.hereMapControllerCore.addMapIdleListener(_idleListener!);
    } catch (e) {
      // Fallback: if idle listener is not available on this build, poll via debounce on a timer after camera operations.
      debugPrint('MapIdleListener not available, using timed refresh. $e');
      // Initial periodic fallback every 1.5s while map is shown
      _debounce?.cancel();
      _debounce = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _refreshHeatmap(),
      );
    }
  }

  void _scheduleHeatmapUpdate() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _refreshHeatmap);
  }

  Future<void> _refreshHeatmap() async {
    debugPrint('[HERE] _refreshHeatmap() called');
    final ctrl = _controller;
    if (ctrl == null) return;
    
    // Prevent simultaneous requests
    if (_isLoadingHeatmap) {
      debugPrint('[HERE] Already loading, skipping...');
      return;
    }

    // Get visible bounds
    final box = ctrl.camera.boundingBox;
    debugPrint('[HERE] camera.boundingBox = $box');
    if (box == null) {
      // bounding box ainda não disponível; tenta novamente em 200ms
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 200), _refreshHeatmap);
      return;
    }

    final minLat = box.southWestCorner.latitude;
    final minLng = box.southWestCorner.longitude;
    final maxLat = box.northEastCorner.latitude;
    final maxLng = box.northEastCorner.longitude;

    // Zoom (rounded) to help server aggregate
    int zoom = ctrl.camera.state.zoomLevel.round();
    
    // Create cache key from bounds
    final boundsKey = '${minLat.toStringAsFixed(4)},${minLng.toStringAsFixed(4)},${maxLat.toStringAsFixed(4)},${maxLng.toStringAsFixed(4)},$zoom';
    
    // Check if bounds changed
    if (_lastBoundsKey == boundsKey) {
      debugPrint('[HERE] Bounds unchanged, skipping request');
      return;
    }
    
    debugPrint('[HERE] bounds: [$minLat,$minLng]-[$maxLat,$maxLng] zoom=$zoom');
    _lastBoundsKey = boundsKey;
    _isLoadingHeatmap = true;

    try {
      final token = await ApiClient().getToken();
      final requiresAuth = token != null && token.isNotEmpty;

      final points = await _heatmapService.fetchHeatmapByBounds(
        minLat: minLat,
        minLng: minLng,
        maxLat: maxLat,
        maxLng: maxLng,
        zoom: zoom,
        requiresAuth: requiresAuth,
      );

      // Replace overlays
      _clearHeatPolygons();
      debugPrint('[HERE] heatmap points fetched: ${points.length}');
      
      // Only setState if data actually changed
      final newPointsCount = points.length;
      final newStatusMessage = points.isEmpty ? 'Sem pontos de calor na área visível.' : null;
      
      if (_lastPointsCount != newPointsCount || _statusMessage != newStatusMessage) {
        if (mounted) {
          setState(() {
            _lastPointsCount = newPointsCount;
            _statusMessage = newStatusMessage;
          });
        }
      }

      // Fallback: se o endpoint de heatmap não retornar pontos, tenta sem bounds (backend usa área padrão).
      if (points.isEmpty) {
        try {
          debugPrint('[HERE] No points in current bounds. Trying default bounds...');
          final rawDefault = await _occurrenceService.getHeatmapRaw(requiresAuth: requiresAuth);
          final defaultPoints = _heatmapService.parseHeatmapPoints(rawDefault);
          
          if (defaultPoints.isNotEmpty && rawDefault['bounds'] != null) {
            final b = rawDefault['bounds'] as Map<String, dynamic>;
            final centerLat = ((b['minLat'] as num) + (b['maxLat'] as num)) / 2.0;
            final centerLng = ((b['minLng'] as num) + (b['maxLng'] as num)) / 2.0;
            
            // Move camera to default bounds center
            final newTarget = GeoCoordinates(centerLat, centerLng);
            final newDistance = MapMeasure(MapMeasureKind.distanceInMeters, 12000);
            ctrl.camera.lookAtPointWithMeasure(newTarget, newDistance);
            
            // Draw default points
            for (final p in defaultPoints) {
              final radius = _radiusFor(p.intensity, 12);
              final color = _colorFor(p.intensity);
              final circle = GeoCircle(GeoCoordinates(p.lat, p.lng), radius);
              final polygon = MapPolygon(GeoPolygon.withGeoCircle(circle), color);
              polygon.drawOrder = 100;
              ctrl.mapScene.addMapPolygon(polygon);
              _heatPolygons.add(polygon);
            }
            
            if (mounted) {
              setState(() {
                _lastPointsCount = defaultPoints.length;
                _statusMessage = 'Mapa movido para área com dados (${defaultPoints.length} pontos).';
              });
            }
            debugPrint('[HERE] Moved to default bounds with ${defaultPoints.length} points');
            return;
          }
          
          // Se ainda vazio, tenta nearby
          debugPrint('[HERE] Default bounds also empty. Trying nearby...');
          final center = ctrl.camera.state.targetCoordinates;
          final fallbackRadius = zoom >= 16 ? 300 : zoom >= 14 ? 800 : zoom >= 12 ? 1500 : 3000;
          
          final occs = await _occurrenceService.getNearbyOccurrences(
            latitude: center.latitude,
            longitude: center.longitude,
            radiusMeters: fallbackRadius,
          );
          debugPrint('[HERE] nearby occurrences fetched: ${occs.length}');
          
          if (occs.isEmpty) {
            if (mounted) {
              setState(() {
                _statusMessage = 'Sem ocorrências na área visível. Tente mover o mapa ou reduzir o zoom.';
              });
            }
          } else {
            for (final o in occs) {
              final radius = _radiusFor(1, zoom);
              final color = _colorFor(3);
              final circle = GeoCircle(GeoCoordinates(o.latitude, o.longitude), radius);
              final polygon = MapPolygon(GeoPolygon.withGeoCircle(circle), color);
              polygon.drawOrder = 100;
              ctrl.mapScene.addMapPolygon(polygon);
              _heatPolygons.add(polygon);
            }
            if (mounted) {
              setState(() {
                _lastPointsCount = occs.length;
                _statusMessage = null;
              });
            }
          }
        } catch (e) {
          debugPrint('[HERE] All fallbacks failed: $e');
          if (mounted) {
            setState(() {
              _statusMessage = 'Não foi possível carregar dados. Verifique conexão e API_BASE_URL.';
            });
          }
        }
        return;
      }

      for (final p in points) {
        final radius = _radiusFor(p.intensity, zoom);
        final color = _colorFor(p.intensity);

        final circle = GeoCircle(GeoCoordinates(p.lat, p.lng), radius);
        final polygon = MapPolygon(GeoPolygon.withGeoCircle(circle), color);
        // Ensure beneath markers
        polygon.drawOrder = 100;

        ctrl.mapScene.addMapPolygon(polygon);
        _heatPolygons.add(polygon);
      }
      // Optionally, adjust visibility ranges by zoom to avoid clutter
      // (skipped for simplicity)
    } on UnauthorizedException catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Modo anônimo: faça login para ver o mapa de calor.';
        });
      }
      debugPrint('[HERE] Unauthorized: $e');
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Erro ao carregar heatmap: ${e.message}';
        });
      }
      debugPrint('[HERE] API error: ${e.message}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage =
              'Falha ao conectar no servidor. Verifique API_BASE_URL e rede.';
        });
      }
      debugPrint('[HERE] Failed to load heatmap: $e');
    } finally {
      _isLoadingHeatmap = false;
    }
  }

  void _clearHeatPolygons() {
    final ctrl = _controller;
    if (ctrl == null) {
      _heatPolygons.clear();
      return;
    }
    for (final poly in _heatPolygons) {
      try {
        ctrl.mapScene.removeMapPolygon(poly);
      } catch (_) {}
    }
    _heatPolygons.clear();
  }

  // Radius in meters based on intensity and zoom
  double _radiusFor(int intensity, int zoom) {
    final i = intensity.clamp(1, 10);
    double base;
    if (zoom >= 16) {
      base = 50;
    } else if (zoom >= 14) {
      base = 80;
    } else if (zoom >= 12) {
      base = 120;
    } else {
      base = 180;
    }
    // Scale radius slightly with intensity
    final scale = 0.7 + (i / 10.0) * 0.6; // 0.7 .. 1.3
    return base * scale;
  }

  // Color gradient based on intensity (orange -> red) with alpha
  Color _colorFor(int intensity) {
    final i = intensity.clamp(1, 10);
    final t = (i - 1) / 9.0; // 0..1
    final base = Color.lerp(Colors.orange, Colors.red, t) ?? Colors.red;
    return base.withOpacity(0.35 + 0.25 * t); // 0.35 .. 0.60
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          HereMap(onMapCreated: _onMapCreated),
          if (_statusMessage != null)
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                elevation: 2,
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    _lastPointsCount == null
                        ? ''
                        : 'Heat pts: ${_lastPointsCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          if (_statusMessage != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                elevation: 2,
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _statusMessage = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
