import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:nexasafety/core/config.dart';
import 'package:nexasafety/core/services/api_client.dart';
import 'package:nexasafety/models/api_occurrence.dart';

class OccurrenceService {
  OccurrenceService._internal();
  static final OccurrenceService _instance = OccurrenceService._internal();
  factory OccurrenceService() => _instance;

  final _api = ApiClient();

  // POST /occurrences (JSON)
  Future<ApiOccurrence> createOccurrence({
    required String tipo, // esperado pelo backend: 'roubo' | 'furto' | 'vandalismo' | 'assalto' | 'ameaca' | 'outros'
    required String descricao,
    required double latitude,
    required double longitude,
    bool isPublic = true,
    List<String> mediaUrls = const [],
  }) async {
    final res = await _api.post('/occurrences', {
      'tipo': tipo,
      'descricao': descricao,
      'latitude': latitude,
      'longitude': longitude,
      'isPublic': isPublic,
      'mediaUrls': mediaUrls,
    }, requiresAuth: true);

    return ApiOccurrence.fromJson(json.decode(res.body) as Map<String, dynamic>);
  }

  // POST /occurrences/with-media (multipart)
  Future<ApiOccurrence> createOccurrenceWithMedia({
    required String tipo,
    required String descricao,
    required double latitude,
    required double longitude,
    required List<File> mediaFiles,
    bool isPublic = true,
  }) async {
    final token = await _api.getToken();

    final uri = Uri.parse('${Config.apiBaseUrl}/occurrences/with-media');
    final request = http.MultipartRequest('POST', uri);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['tipo'] = tipo;
    request.fields['descricao'] = descricao;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['isPublic'] = isPublic.toString();

    for (final file in mediaFiles) {
      final mimeType = lookupMimeType(file.path);
      final contentType = mimeType != null ? MediaType.parse(mimeType) : null;

      final mpFile = await http.MultipartFile.fromPath(
        'files',
        file.path,
        contentType: contentType,
      );
      request.files.add(mpFile);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiOccurrence.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      try {
        final body = json.decode(response.body);
        throw ApiException(body['message']?.toString() ?? 'Erro ao criar ocorrência');
      } catch (_) {
        throw ApiException('Erro ${response.statusCode}: ${response.reasonPhrase}');
      }
    }
  }

  // GET /occurrences/my
  Future<List<ApiOccurrence>> getMyOccurrences() async {
    final res = await _api.get('/occurrences/my', requiresAuth: true);
    final List<dynamic> data = json.decode(res.body) as List<dynamic>;
    return data.map((e) => ApiOccurrence.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /occurrences (com paginação/filtros)
  Future<PaginatedOccurrences> getOccurrences({
    int page = 1,
    int limit = 50,
    String? tipo,
    String? bairro,
  }) async {
    final res = await _api.get(
      '/occurrences',
      requiresAuth: true,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (tipo != null) 'tipo': tipo,
        if (bairro != null) 'bairro': bairro,
      },
    );

    return PaginatedOccurrences.fromJson(json.decode(res.body) as Map<String, dynamic>);
  }

  // GET /occurrences/nearby
  Future<List<ApiOccurrence>> getNearbyOccurrences({
    required double latitude,
    required double longitude,
    int radiusMeters = 1000,
  }) async {
    final uriParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radius': radiusMeters.toString(),
    };

    // nearby não exige auth no guia; usando sem requiresAuth
    final res = await _api.get('/occurrences/nearby', requiresAuth: false, queryParams: uriParams);
    final List<dynamic> data = json.decode(res.body) as List<dynamic>;
    return data.map((e) => ApiOccurrence.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /occurrences/:id
  Future<ApiOccurrence> getById(String id) async {
    final res = await _api.get('/occurrences/$id', requiresAuth: true);
    return ApiOccurrence.fromJson(json.decode(res.body) as Map<String, dynamic>);
  }
}
