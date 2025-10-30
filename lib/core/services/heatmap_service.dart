import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexasafety/core/services/occurrence_service.dart';
import 'package:nexasafety/models/api_occurrence.dart';

/// Service responsible for fetching and transforming occurrence data
/// into heatmap-compatible format with caching support
class HeatmapPoint {
  final double lat;
  final double lng;
  final int intensity;
  final List<String> tipos;

  HeatmapPoint({
    required this.lat,
    required this.lng,
    required this.intensity,
    this.tipos = const [],
  });

  factory HeatmapPoint.fromMap(Map<String, dynamic> m) {
    return HeatmapPoint(
      lat: (m['lat'] as num).toDouble(),
      lng: (m['lng'] as num).toDouble(),
      intensity: (m['intensity'] as num?)?.toInt() ?? 1,
      tipos: m['tipos'] != null
          ? List<String>.from(m['tipos'] as List)
          : const [],
    );
  }
}

class HeatmapService {
  HeatmapService._internal();
  static final HeatmapService _instance = HeatmapService._internal();
  factory HeatmapService() => _instance;

  final _occurrenceService = OccurrenceService();

  // Cache configuration
  static const String _cacheKey = 'heatmap_data_timestamp';
  static const Duration _cacheExpiration = Duration(minutes: 15);

  // Cached data
  List<ApiOccurrence>? _cachedOccurrences;
  DateTime? _lastFetch;

  /// Fetches all occurrences for heatmap visualization
  /// Uses pagination to retrieve all data
  /// Results are cached for 15 minutes to reduce API calls
  Future<List<ApiOccurrence>> fetchOccurrences({
    bool forceRefresh = false,
  }) async {
    // Return cached data if still valid
    if (!forceRefresh && _cachedOccurrences != null && _lastFetch != null) {
      final timeSinceLastFetch = DateTime.now().difference(_lastFetch!);
      if (timeSinceLastFetch < _cacheExpiration) {
        return _cachedOccurrences!;
      }
    }

    // Fetch all occurrences using pagination
    final allOccurrences = <ApiOccurrence>[];
    int currentPage = 1;
    bool hasMore = true;
    const int pageSize = 100; // Large page size to minimize requests

    while (hasMore) {
      try {
        final result = await _occurrenceService.getOccurrences(
          page: currentPage,
          limit: pageSize,
        );

        allOccurrences.addAll(result.data);

        hasMore = result.hasNext;
        currentPage++;

        // Safety limit to prevent infinite loops
        if (currentPage > 50) {
          break;
        }
      } catch (e) {
        // If first page fails, rethrow. Otherwise, return what we have
        if (currentPage == 1) {
          rethrow;
        }
        break;
      }
    }

    // Update cache
    _cachedOccurrences = allOccurrences;
    _lastFetch = DateTime.now();
    await _saveCacheTimestamp();

    return allOccurrences;
  }

  /// Fetch aggregated heatmap points from backend using visible bounds
  /// This calls GET /occurrences/heatmap which returns:
  /// {
  ///   points: [{ lat, lng, intensity, tipos: [...] }...],
  ///   total: number,
  ///   bounds: { minLat, minLng, maxLat, maxLng }
  /// }
  Future<List<HeatmapPoint>> fetchHeatmapByBounds({
    required double minLat,
    required double minLng,
    required double maxLat,
    required double maxLng,
    int zoom = 14,
    bool requiresAuth = true,
  }) async {
    final raw = await _occurrenceService.getHeatmapRaw(
      minLat: minLat,
      minLng: minLng,
      maxLat: maxLat,
      maxLng: maxLng,
      zoom: zoom,
      requiresAuth: requiresAuth,
    );

    // Tenta formatos alternativos do backend para maior resiliência.
    return parseHeatmapPoints(raw);
  }

  // Aceita as seguintes formas de resposta:
  // 1) { points: [{ lat, lng, intensity, tipos? }], total?, bounds? }
  // 2) { data:  [{ lat|latitude|coordenadas.lat, lng|longitude|coordenadas.lng, intensity?, tipo? }], ... }
  // 3) { ocorrencias: [{ ... campos variáveis ... }] } -> converte para pontos básicos (intensity=1)
  List<HeatmapPoint> parseHeatmapPoints(Map<String, dynamic> raw) {
    List dynamicList = const [];

    if (raw['points'] is List) {
      dynamicList = raw['points'] as List;
      return dynamicList
          .whereType<Map<String, dynamic>>()
          .map((e) => HeatmapPoint.fromMap(e))
          .toList();
    }

    if (raw['data'] is List) {
      dynamicList = raw['data'] as List;
      return dynamicList
          .whereType<Map<String, dynamic>>()
          .map((e) {
            final m = e;
            final coords = (m['coordenadas'] is Map)
                ? (m['coordenadas'] as Map)
                : null;
            final num? latNum =
                (m['lat'] as num?) ??
                (m['latitude'] as num?) ??
                (coords != null ? coords['lat'] as num? : null);
            final num? lngNum =
                (m['lng'] as num?) ??
                (m['longitude'] as num?) ??
                (coords != null ? coords['lng'] as num? : null);
            if (latNum == null || lngNum == null) {
              return null;
            }
            final tipos = <String>[];
            if (m['tipos'] is List) {
              tipos.addAll(List<String>.from(m['tipos'] as List));
            } else if (m['tipo'] is String) {
              tipos.add(m['tipo'] as String);
            }
            final intensity = (m['intensity'] as num?)?.toInt() ?? 1;
            return HeatmapPoint(
              lat: latNum.toDouble(),
              lng: lngNum.toDouble(),
              intensity: intensity,
              tipos: tipos,
            );
          })
          .whereType<HeatmapPoint>()
          .toList();
    }

    if (raw['ocorrencias'] is List) {
      dynamicList = raw['ocorrencias'] as List;
      return dynamicList
          .whereType<Map<String, dynamic>>()
          .map((m) {
            final coords = (m['coordenadas'] is Map)
                ? (m['coordenadas'] as Map)
                : null;
            final num? latNum =
                (coords != null ? coords['lat'] as num? : null) ??
                (m['latitude'] as num?);
            final num? lngNum =
                (coords != null ? coords['lng'] as num? : null) ??
                (m['longitude'] as num?);
            if (latNum == null || lngNum == null) {
              return null;
            }
            final tipo = m['tipo']?.toString();
            final tipos = tipo != null ? <String>[tipo] : const <String>[];
            return HeatmapPoint(
              lat: latNum.toDouble(),
              lng: lngNum.toDouble(),
              intensity: 1,
              tipos: tipos,
            );
          })
          .whereType<HeatmapPoint>()
          .toList();
    }

    // Sem correspondência conhecida: retorna vazio.
    return const <HeatmapPoint>[];
  }

  /// Filter occurrences by type and date
  /// Returns filtered list of occurrences for visualization
  List<ApiOccurrence> filterOccurrences(
    List<ApiOccurrence> occurrences, {
    String? filterByType,
    DateTime? afterDate,
  }) {
    var filtered = occurrences;

    // Filter by type if specified
    if (filterByType != null && filterByType.isNotEmpty) {
      filtered = filtered.where((o) => o.tipo == filterByType).toList();
    }

    // Filter by date if specified
    if (afterDate != null) {
      filtered = filtered.where((o) => o.createdAt.isAfter(afterDate)).toList();
    }

    return filtered;
  }

  /// Get occurrences grouped by type for filter UI
  Map<String, int> getOccurrenceCountByType(List<ApiOccurrence> occurrences) {
    final counts = <String, int>{};

    for (final occurrence in occurrences) {
      counts[occurrence.tipo] = (counts[occurrence.tipo] ?? 0) + 1;
    }

    return counts;
  }

  /// Get occurrences within a time range
  List<ApiOccurrence> filterByTimeRange(
    List<ApiOccurrence> occurrences,
    Duration timeRange,
  ) {
    final cutoffDate = DateTime.now().subtract(timeRange);
    return occurrences.where((o) => o.createdAt.isAfter(cutoffDate)).toList();
  }

  /// Clear cached data
  void clearCache() {
    _cachedOccurrences = null;
    _lastFetch = null;
  }

  /// Save cache timestamp to SharedPreferences
  Future<void> _saveCacheTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if cache is expired
  Future<bool> isCacheExpired() async {
    if (_lastFetch == null) return true;

    final timeSinceLastFetch = DateTime.now().difference(_lastFetch!);
    return timeSinceLastFetch >= _cacheExpiration;
  }

  /// Get cache age in minutes
  int? getCacheAgeInMinutes() {
    if (_lastFetch == null) return null;
    return DateTime.now().difference(_lastFetch!).inMinutes;
  }
}
