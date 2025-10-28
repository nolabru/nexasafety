class Occurrence {
  final String id;
  final String type; // 'assalto' | 'furto' | 'vandalismo' | 'suspeita' | 'concluido'
  final String description;
  final double lat;
  final double lng;
  final bool anonymous;
  final DateTime createdAt;

  Occurrence({
    required this.id,
    required this.type,
    required this.description,
    required this.lat,
    required this.lng,
    required this.anonymous,
    required this.createdAt,
  });
}

const occurrenceTypes = <String>[
  'assalto',
  'furto',
  'vandalismo',
  'suspeita',
  'concluido',
];

String labelForType(String type) {
  switch (type) {
    case 'assalto':
      return 'Assalto/Roubo';
    case 'furto':
      return 'Furto';
    case 'vandalismo':
      return 'Vandalismo';
    case 'suspeita':
      return 'Suspeita/Outros';
    case 'concluido':
      return 'Concluído';
    default:
      return type;
  }
}
