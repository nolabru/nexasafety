import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/enums/occurrence_enums.dart';

class OccurrenceCard extends StatelessWidget {
  final String id;
  final OccurrenceType type;
  final OccurrenceStatus status;
  final String description;
  final String date;
  final VoidCallback onTap;

  const OccurrenceCard({
    super.key,
    required this.id,
    required this.type,
    required this.status,
    required this.description,
    required this.date,
    required this.onTap,
  });

  Color _getStatusColor() {
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

  IconData _getTypeIcon() {
    // Simplified icon mapping - you can expand this
    switch (type) {
      case OccurrenceType.furto:
      case OccurrenceType.roubo:
        return Icons.shopping_bag_outlined;
      case OccurrenceType.vandalismo:
        return Icons.warning_outlined;
      case OccurrenceType.agressao:
        return Icons.person_outline;
      case OccurrenceType.acidenteTransito:
        return Icons.car_crash_outlined;
      default:
        return Icons.report_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusLabel = OccurrenceEnumHelper.getStatusLabel(status);
    final typeLabel = OccurrenceEnumHelper.getTypeLabel(type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: statusColor,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusLabel,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            typeLabel,
                            style: AppTextStyles.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Description
                    Text(
                      description,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Date
                    Text(
                      date,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
