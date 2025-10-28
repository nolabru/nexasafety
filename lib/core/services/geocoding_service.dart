import 'dart:convert';
import 'package:nexasafety/core/services/api_client.dart';
import 'package:nexasafety/core/config.dart';
import 'package:http/http.dart' as http;

class GeocodeResult {
  final String endereco;
  final String bairro;
  final String cidade;
  final String estado;
  final String pais;
  final double latitude;
  final double longitude;

  GeocodeResult({
    required this.endereco,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.pais,
    required this.latitude,
    required this.longitude,
  });

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    return GeocodeResult(
      endereco: json['endereco'] as String,
      bairro: json['bairro'] as String,
      cidade: json['cidade'] as String,
      estado: json['estado'] as String,
      pais: json['pais'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class BairroValidation {
  final String bairro;
  final bool valido;
  final List<String>? sugestoes;

  BairroValidation({
    required this.bairro,
    required this.valido,
    this.sugestoes,
  });

  factory BairroValidation.fromJson(Map<String, dynamic> json) {
    return BairroValidation(
      bairro: json['bairro'] as String,
      valido: json['valido'] as bool,
      sugestoes: json['sugestoes'] != null
          ? List<String>.from(json['sugestoes'])
          : null,
    );
  }
}

class GeocodingService {
  GeocodingService._internal();
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;

  final _api = ApiClient();

  Future<GeocodeResult> reverseGeocode(double lat, double lng) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/geocoding/reverse').replace(
      queryParameters: {
        'latitude': lat.toString(),
        'longitude': lng.toString(),
      },
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return GeocodeResult.fromJson(json.decode(res.body) as Map<String, dynamic>);
      } else {
        throw ApiException('Erro ao buscar endereço (${res.statusCode})');
      }
    } catch (e) {
      throw ApiException('Erro de conexão: $e');
    }
  }

  Future<List<String>> getBairrosSalvador() async {
    final uri = Uri.parse('${Config.apiBaseUrl}/geocoding/bairros');
    try {
      final res = await http.get(uri);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        return List<String>.from(data['bairros'] as List);
      } else {
        throw ApiException('Erro ao carregar bairros (${res.statusCode})');
      }
    } catch (e) {
      throw ApiException('Erro de conexão: $e');
    }
  }

  Future<BairroValidation> validateBairro(String bairro) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/geocoding/validate-bairro').replace(
      queryParameters: {'bairro': bairro},
    );
    try {
      final res = await http.get(uri);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return BairroValidation.fromJson(json.decode(res.body) as Map<String, dynamic>);
      } else {
        throw ApiException('Erro ao validar bairro (${res.statusCode})');
      }
    } catch (e) {
      throw ApiException('Erro de conexão: $e');
    }
  }
}
