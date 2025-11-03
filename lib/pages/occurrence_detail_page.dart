import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/enums/occurrence_enums.dart';
import '../core/services/occurrence_service.dart';
import '../models/api_occurrence.dart';
import '../widgets/custom_snackbar.dart';

class OccurrenceDetailPage extends StatefulWidget {
  final String occurrenceId;

  const OccurrenceDetailPage({super.key, required this.occurrenceId});

  @override
  State<OccurrenceDetailPage> createState() => _OccurrenceDetailPageState();
}

class _OccurrenceDetailPageState extends State<OccurrenceDetailPage> {
  final _occurrenceService = OccurrenceService();
  ApiOccurrence? _occurrence;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOccurrence();
  }

  Future<void> _loadOccurrence() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final occurrence = await _occurrenceService.getById(widget.occurrenceId);
      setState(() {
        _occurrence = occurrence;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar ocorrência: $e';
        _isLoading = false;
      });
    }
  }

  OccurrenceType _mapTypeFromApi(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'roubo':
        return OccurrenceType.roubo;
      case 'furto':
        return OccurrenceType.furto;
      case 'vandalismo':
        return OccurrenceType.vandalismo;
      case 'assalto':
        return OccurrenceType.assalto;
      case 'agressao':
      case 'agressão':
        return OccurrenceType.agressao;
      case 'acidente_transito':
      case 'acidente de trânsito':
        return OccurrenceType.acidenteTransito;
      case 'perturbacao':
      case 'perturbação':
        return OccurrenceType.perturbacao;
      case 'violencia_domestica':
      case 'violência doméstica':
        return OccurrenceType.violenciaDomestica;
      case 'trafico':
      case 'tráfico':
        return OccurrenceType.trafico;
      case 'homicidio':
      case 'homicídio':
        return OccurrenceType.homicidio;
      case 'desaparecimento':
        return OccurrenceType.desaparecimento;
      case 'incendio':
      case 'incêndio':
        return OccurrenceType.incendio;
      default:
        return OccurrenceType.outros;
    }
  }

  OccurrenceStatus _mapStatusFromApi(String? status) {
    if (status == null) return OccurrenceStatus.enviado;

    switch (status.toLowerCase()) {
      case 'enviado':
      case 'pending':
        return OccurrenceStatus.enviado;
      case 'analise':
      case 'em análise':
      case 'in_progress':
        return OccurrenceStatus.analise;
      case 'concluido':
      case 'concluído':
      case 'resolved':
        return OccurrenceStatus.concluido;
      case 'rejeitado':
      case 'rejected':
        return OccurrenceStatus.rejeitado;
      default:
        return OccurrenceStatus.enviado;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatAddress(ApiOccurrence occurrence) {
    final parts = <String>[];

    if (occurrence.endereco != null && occurrence.endereco!.isNotEmpty) {
      parts.add(occurrence.endereco!);
    }
    if (occurrence.bairro != null && occurrence.bairro!.isNotEmpty) {
      parts.add(occurrence.bairro!);
    }
    if (occurrence.cidade != null && occurrence.cidade!.isNotEmpty) {
      parts.add(occurrence.cidade!);
    }
    if (occurrence.estado != null && occurrence.estado!.isNotEmpty) {
      parts.add(occurrence.estado!);
    }

    parts.add(
      '${occurrence.latitude.toStringAsFixed(6)}, ${occurrence.longitude.toStringAsFixed(6)}',
    );

    return parts.join('\n');
  }

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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Detalhe da Ocorrência',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _occurrence == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Detalhe da Ocorrência',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.statusRejeitado,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage ?? 'Ocorrência não encontrada',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOccurrence,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final type = _mapTypeFromApi(_occurrence!.tipo);
    final status = _mapStatusFromApi(_occurrence!.status);
    final statusColor = _getStatusColor(status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhe da Ocorrência',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
              CustomSnackBar.show(
                context,
                message: 'Compartilhar em desenvolvimento',
                type: SnackBarType.info,
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
                          _formatDate(_occurrence!.createdAt),
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
                  Text('Descrição', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    _occurrence!.descricao,
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
          if (_occurrence!.media != null && _occurrence!.media!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Imagens/Vídeos', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _occurrence!.media!.length,
                        itemBuilder: (context, index) {
                          final mediaItem = _occurrence!.media![index];
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(mediaItem.url),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
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
                  Text('Localização', style: AppTextStyles.titleMedium),
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
                          _formatAddress(_occurrence!),
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
                  Text('Status', style: AppTextStyles.titleMedium),
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
                  Text('Informações', style: AppTextStyles.titleMedium),
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
                border: Border.all(color: color, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: color.withOpacity(0.3)),
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
