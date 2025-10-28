import 'dart:convert';
import 'package:nexasafety/core/services/api_client.dart';
import 'package:nexasafety/models/user.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final _api = ApiClient();

  Future<User> register({
    required String email,
    required String password,
    required String nome,
    required String telefone,
  }) async {
    final res = await _api.post('/auth/register', {
      'email': email,
      'password': password,
      'nome': nome,
      'telefone': telefone,
    }, requiresAuth: false);

    final data = json.decode(res.body) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    }, requiresAuth: false);

    final data = json.decode(res.body) as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    await _api.saveToken(accessToken);

    return LoginResponse(
      accessToken: accessToken,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<User> me() async {
    final res = await _api.get('/auth/me', requiresAuth: true);
    final data = json.decode(res.body) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<void> logout() async {
    await _api.clearToken();
  }
}

class LoginResponse {
  final String accessToken;
  final User user;

  LoginResponse({required this.accessToken, required this.user});
}
