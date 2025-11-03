import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:nexasafety/core/config.dart';

class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }

  Uri _buildUri(String endpoint, {Map<String, String>? queryParams}) {
    return Uri.parse('${Config.apiBaseUrl}$endpoint').replace(
      queryParameters: queryParams,
    );
  }

  String get baseUrl => Config.apiBaseUrl;

  /// Decodifica resposta JSON
  dynamic decodeResponse(String body) {
    return json.decode(body);
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint, queryParams: queryParams);
    final headers = await _buildHeaders(requiresAuth: requiresAuth);
    try {
      final response = await http.get(uri, headers: headers);
      final validatedResponse = _handleResponse(response);
      return json.decode(validatedResponse.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: $e');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = await _buildHeaders(requiresAuth: requiresAuth);
    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: data != null ? json.encode(data) : null,
      );
      final validatedResponse = _handleResponse(response);
      return json.decode(validatedResponse.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: $e');
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = await _buildHeaders(requiresAuth: requiresAuth);
    try {
      final response = await http.patch(
        uri,
        headers: headers,
        body: data != null ? json.encode(data) : null,
      );
      final validatedResponse = _handleResponse(response);
      return json.decode(validatedResponse.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: $e');
    }
  }

  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = await _buildHeaders(requiresAuth: requiresAuth);
    try {
      final response = await http.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erro de conexão: $e');
    }
  }

  Future<Map<String, String>> _buildHeaders({required bool requiresAuth}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'accept': '*/*',
    };
    if (requiresAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    if (response.statusCode == 401) {
      // limpa token inválido/expirado
      clearToken();
      throw UnauthorizedException('Token inválido ou expirado');
    }
    if (response.statusCode == 403) {
      throw ForbiddenException('Acesso negado');
    }
    if (response.statusCode == 404) {
      throw NotFoundException('Recurso não encontrado');
    }
    try {
      final body = json.decode(response.body);
      throw ApiException(body['message']?.toString() ?? 'Erro desconhecido');
    } catch (_) {
      throw ApiException('Erro ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}

// Exceções
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}
