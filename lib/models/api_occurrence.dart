import 'package:flutter/material.dart';
import 'package:nexasafety/models/media.dart';
import 'package:nexasafety/models/user.dart';

class ApiOccurrence {
  final String id;
  final String tipo; // lowercase: roubo, furto, vandalismo, assalto, agressao, acidente_transito, etc.
  final String descricao;
  final double latitude;
  final double longitude;
  final String? endereco;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String status; // lowercase: enviado, analise, concluido, rejeitado
  final bool isPublic;
  final String? usuarioId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final User? usuario;
  final List<Media>? media;

  ApiOccurrence({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    this.endereco,
    this.bairro,
    this.cidade,
    this.estado,
    required this.status,
    required this.isPublic,
    required this.usuarioId,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.usuario,
    this.media,
  });

  factory ApiOccurrence.fromJson(Map<String, dynamic> json) {
    return ApiOccurrence(
      id: json['id'] as String,
      tipo: json['tipo'] as String,
      descricao: json['descricao'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      endereco: json['endereco'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      status: json['status'] as String,
      isPublic: json['isPublic'] as bool? ?? true,
      usuarioId: json['usuarioId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      usuario: json['usuario'] != null ? User.fromJson(json['usuario']) : null,
      media: json['media'] != null
          ? (json['media'] as List).map((m) => Media.fromJson(m)).toList()
          : null,
    );
  }

  // Helpers opcionais (cores/ícones por tipo) para UI
  Color getColorByType() {
    switch (tipo.toLowerCase()) {
      case 'roubo':
      case 'assalto':
        return Colors.red;
      case 'furto':
        return Colors.orange;
      case 'vandalismo':
        return Colors.purple;
      case 'agressao':
      case 'violencia_domestica':
        return Colors.deepOrange;
      case 'ameaca':
        return Colors.amber;
      case 'homicidio':
        return Colors.red.shade900;
      case 'trafico':
        return Colors.purple.shade900;
      case 'acidente_transito':
        return Colors.blue;
      case 'incendio':
        return Colors.deepOrange.shade900;
      default:
        return Colors.grey;
    }
  }

  IconData getIconByType() {
    switch (tipo.toLowerCase()) {
      case 'roubo':
      case 'assalto':
        return Icons.dangerous;
      case 'furto':
        return Icons.shopping_bag;
      case 'vandalismo':
        return Icons.broken_image;
      case 'agressao':
        return Icons.front_hand;
      case 'ameaca':
        return Icons.warning;
      case 'acidente_transito':
        return Icons.car_crash;
      case 'homicidio':
        return Icons.warning_amber;
      case 'trafico':
        return Icons.medication;
      case 'violencia_domestica':
        return Icons.home;
      case 'incendio':
        return Icons.local_fire_department;
      case 'desaparecimento':
        return Icons.person_search;
      default:
        return Icons.report;
    }
  }

  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'enviado':
        return 'Enviado';
      case 'analise':
        return 'Em análise';
      case 'concluido':
        return 'Concluída';
      case 'rejeitado':
        return 'Rejeitada';
      default:
        return status;
    }
  }
}

class PaginatedOccurrences {
  final List<ApiOccurrence> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedOccurrences({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedOccurrences.fromJson(Map<String, dynamic> json) {
    return PaginatedOccurrences(
      data: (json['data'] as List).map((e) => ApiOccurrence.fromJson(e)).toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );
  }
}
