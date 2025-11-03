import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Atualizar perfil do usuário (nome, email, telefone)
  Future<User> updateProfile({
    required String userId,
    String? nome,
    String? email,
    String? telefone,
  }) async {
    final Map<String, dynamic> data = {};

    if (nome != null) data['nome'] = nome;
    if (email != null) data['email'] = email;
    if (telefone != null) data['telefone'] = telefone;

    final response = await _apiClient.patch(
      '/users/$userId/profile',
      data: data,
    );

    return User.fromJson(response);
  }

  /// Upload de foto de perfil
  Future<User> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    final token = await _apiClient.getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    // Criar multipart request
    final uri = Uri.parse('${_apiClient.baseUrl}/users/$userId/profile-photo');
    final request = http.MultipartRequest('PATCH', uri);

    // Adicionar token de autenticação
    request.headers['Authorization'] = 'Bearer $token';

    // Detectar tipo MIME do arquivo
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    final mimeData = mimeType.split('/');

    // Adicionar arquivo
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType(mimeData[0], mimeData[1]),
      ),
    );

    // Enviar requisição
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = _apiClient.decodeResponse(response.body);
      return User.fromJson(data);
    } else {
      final error = _apiClient.decodeResponse(response.body);
      throw Exception(error['message'] ?? 'Erro ao fazer upload da foto');
    }
  }

  /// Buscar perfil do usuário atual
  Future<User> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me');
    return User.fromJson(response);
  }

  /// Buscar usuário por ID
  Future<User> getUserById(String userId) async {
    final response = await _apiClient.get('/users/$userId');
    return User.fromJson(response);
  }
}
