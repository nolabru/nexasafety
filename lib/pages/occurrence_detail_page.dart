import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/enums/occurrence_enums.dart';

class OccurrenceDetailPage extends StatelessWidget {
  final String occurrenceId;

  const OccurrenceDetailPage({
    super.key,
    required this.occurrenceId,
  });

  Color _getStatusColor(OccurrenceStatus status) {
    switch (status) {
      case OccurrenceStatus.enviado:
        return AppColors.statusEnviado;
      case OccurrenceStatus.analise:
        return AppColors.statusAnalise;
      case OccurrenceStatus.concluido:
        return AppColors.statusConcluido;
      case OccurrenceStatus.rejeitado:
        return AppColors.statusRejeitado;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with actual API call
    final occurrence = {
      'id': occurrenceId,
      'type': OccurrenceType.vandalismo,
      'status': OccurrenceStatus.enviado,
      'description': 'Um rapaz alto e cabeludo me abordou, disse que precisava de ajuda e me empurrou na rua, nisso ele pegou minha carteira e meu computador, consegui esconder o celular, mas um absurdo, tudo culpa do lula',
      'date': '01/11/2025',
      'address': 'Avenida das Nações Unidas, 14401, Brasil\nParque da Cidade - Torre Paineira\nSão Paulo, SP\n-37.785834, -122.406417',
      'images': [
        'https://via.placeholder.com/400x300',
      ],
    };

    final type = occurrence['type'] as OccurrenceType;
    final status = occurrence['status'] as OccurrenceStatus;
    final statusColor = _getStatusColor(status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhe da Ocorrência',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compartilhar em desenvolvimento')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type and Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_outlined,
                      color: statusColor,
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Type and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          OccurrenceEnumHelper.getTypeLabel(type),
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          occurrence['date'] as String,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      OccurrenceEnumHelper.getStatusLabel(status),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descrição',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    occurrence['description'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Images/Videos Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Imagens/Vídeos',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/400x300'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Location Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Localização',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  // Map placeholder
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.inputBackground,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.map_outlined,
                        size: 64,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          occurrence['address'] as String,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Timeline Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _StatusTimelineItem(
                    title: 'Recebida',
                    isActive: true,
                    isCompleted: true,
                  ),
                  _StatusTimelineItem(
                    title: 'Em Análise',
                    isActive: status == OccurrenceStatus.analise,
                    isCompleted: status == OccurrenceStatus.concluido,
                  ),
                  _StatusTimelineItem(
                    title: 'Concluída',
                    isActive: false,
                    isCompleted: status == OccurrenceStatus.concluido,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Informações Card (placeholder)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Informações adicionais sobre a ocorrência aparecerão aqui.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatusTimelineItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;

  const _StatusTimelineItem({
    required this.title,
    required this.isActive,
    required this.isCompleted,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? AppColors.statusConcluido
        : isActive
            ? AppColors.statusAnalise
            : AppColors.textLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted || isActive ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: color.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isCompleted || isActive
                  ? AppColors.textPrimary
                  : AppColors.textLight,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
