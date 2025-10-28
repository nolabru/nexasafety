import 'package:flutter/material.dart';
import 'package:nexasafety/models/media.dart';
import 'package:nexasafety/models/user.dart';

class ApiOccurrence {
  final String id;
  final String tipo; // ROUBO, FURTO, VANDALISMO, ASSALTO, AMEACA, OUTROS
  final String descricao;
  final double latitude;
  final double longitude;
  final String? endereco;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String status; // PENDING, IN_PROGRESS, RESOLVED, REJECTED
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
    switch (tipo) {
      case 'ROUBO':
        return Colors.red;
      case 'FURTO':
        return Colors.orange;
      case 'VANDALISMO':
        return Colors.purple;
      case 'ASSALTO':
        return Colors.deepOrange;
      case 'AMEACA':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData getIconByType() {
    switch (tipo) {
      case 'ROUBO':
        return Icons.phone_android;
      case 'FURTO':
        return Icons.shopping_bag;
      case 'VANDALISMO':
        return Icons.broken_image;
      case 'ASSALTO':
        return Icons.dangerous;
      case 'AMEACA':
        return Icons.warning;
      default:
        return Icons.report;
    }
  }

  String getStatusLabel() {
    switch (status) {
      case 'PENDING':
        return 'Pendente';
      case 'IN_PROGRESS':
        return 'Em análise';
      case 'RESOLVED':
        return 'Concluída';
      case 'REJECTED':
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
