import 'dart:async';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexasafety/core/services/occurrence_service.dart';
import 'package:nexasafety/models/api_occurrence.dart';

/// Service responsible for fetching and transforming occurrence data
/// into heatmap-compatible format with caching support
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

  /// Converts occurrences to heatmap weighted lat/lng points
  /// Each occurrence becomes a point with configurable weight
  List<WeightedLatLng> convertToHeatmapData(
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

    // Convert to weighted points
    // Weight can be adjusted based on severity or recency
    return filtered.map((occurrence) {
      return WeightedLatLng(
        LatLng(occurrence.latitude, occurrence.longitude),
        _calculateWeight(occurrence),
      );
    }).toList();
  }

  /// Calculate weight for each occurrence based on type severity
  /// Higher severity crimes get higher weights in the heatmap
  double _calculateWeight(ApiOccurrence occurrence) {
    switch (occurrence.tipo) {
      case 'ASSALTO':
        return 1.0; // Highest severity
      case 'ROUBO':
        return 0.9;
      case 'AMEACA':
        return 0.7;
      case 'FURTO':
        return 0.6;
      case 'VANDALISMO':
        return 0.5;
      default:
        return 0.4; // OUTROS
    }
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
