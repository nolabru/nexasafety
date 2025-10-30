enum OccurrenceStatus {
  enviado,
  analise,
  concluido,
  rejeitado,
}

enum OccurrenceType {
  furto,
  roubo,
  assalto,
  vandalismo,
  agressao,
  acidenteTransito,
  perturbacao,
  violenciaDomestica,
  trafico,
  homicidio,
  desaparecimento,
  incendio,
  outros,
}

enum UserRole {
  citizen,
  moderator,
  admin,
}

// Helper functions for display
class OccurrenceEnumHelper {
  static String getStatusLabel(OccurrenceStatus status) {
    switch (status) {
      case OccurrenceStatus.enviado:
        return 'Enviado';
      case OccurrenceStatus.analise:
        return 'Em Análise';
      case OccurrenceStatus.concluido:
        return 'Concluído';
      case OccurrenceStatus.rejeitado:
        return 'Rejeitado';
    }
  }

  static String getTypeLabel(OccurrenceType type) {
    switch (type) {
      case OccurrenceType.furto:
        return 'Furto';
      case OccurrenceType.roubo:
        return 'Roubo';
      case OccurrenceType.assalto:
        return 'Assalto';
      case OccurrenceType.vandalismo:
        return 'Vandalismo';
      case OccurrenceType.agressao:
        return 'Agressão';
      case OccurrenceType.acidenteTransito:
        return 'Acidente de Trânsito';
      case OccurrenceType.perturbacao:
        return 'Perturbação';
      case OccurrenceType.violenciaDomestica:
        return 'Violência Doméstica';
      case OccurrenceType.trafico:
        return 'Tráfico';
      case OccurrenceType.homicidio:
        return 'Homicídio';
      case OccurrenceType.desaparecimento:
        return 'Desaparecimento';
      case OccurrenceType.incendio:
        return 'Incêndio';
      case OccurrenceType.outros:
        return 'Outros';
    }
  }

  static String getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return 'Cidadão';
      case UserRole.moderator:
        return 'Moderador';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  // Convert string to enum
  static OccurrenceStatus? statusFromString(String value) {
    switch (value.toLowerCase()) {
      case 'enviado':
        return OccurrenceStatus.enviado;
      case 'analise':
        return OccurrenceStatus.analise;
      case 'concluido':
        return OccurrenceStatus.concluido;
      case 'rejeitado':
        return OccurrenceStatus.rejeitado;
      default:
        return null;
    }
  }

  static OccurrenceType? typeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'furto':
        return OccurrenceType.furto;
      case 'roubo':
        return OccurrenceType.roubo;
      case 'assalto':
        return OccurrenceType.assalto;
      case 'vandalismo':
        return OccurrenceType.vandalismo;
      case 'agressao':
        return OccurrenceType.agressao;
      case 'acidente_transito':
        return OccurrenceType.acidenteTransito;
      case 'perturbacao':
        return OccurrenceType.perturbacao;
      case 'violencia_domestica':
        return OccurrenceType.violenciaDomestica;
      case 'trafico':
        return OccurrenceType.trafico;
      case 'homicidio':
        return OccurrenceType.homicidio;
      case 'desaparecimento':
        return OccurrenceType.desaparecimento;
      case 'incendio':
        return OccurrenceType.incendio;
      case 'outros':
        return OccurrenceType.outros;
      default:
        return null;
    }
  }

  // Convert enum to string for API
  static String statusToString(OccurrenceStatus status) {
    return status.name;
  }

  static String typeToString(OccurrenceType type) {
    switch (type) {
      case OccurrenceType.acidenteTransito:
        return 'acidente_transito';
      case OccurrenceType.violenciaDomestica:
        return 'violencia_domestica';
      default:
        return type.name;
    }
  }
}
