class Media {
  final String id;
  final String url;
  final String tipo; // 'image' | 'video'
  final DateTime? createdAt;

  Media({
    required this.id,
    required this.url,
    required this.tipo,
    this.createdAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] as String,
      url: json['url'] as String,
      tipo: json['tipo'] as String,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  bool get isImage => tipo == 'image';
  bool get isVideo => tipo == 'video';

  // Opcional: prefixo padrão localhost; ajuste conforme necessidade
  String get fullUrl => url.startsWith('http') ? url : 'http://localhost:3000$url';
}
