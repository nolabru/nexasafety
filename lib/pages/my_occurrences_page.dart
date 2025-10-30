import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/enums/occurrence_enums.dart';
import '../core/services/occurrence_service.dart';
import '../models/api_occurrence.dart';
import '../widgets/occurrence_card.dart';

class MyOccurrencesPage extends StatefulWidget {
  const MyOccurrencesPage({super.key});

  @override
  State<MyOccurrencesPage> createState() => _MyOccurrencesPageState();
}

class _MyOccurrencesPageState extends State<MyOccurrencesPage> {
  final _occurrenceService = OccurrenceService();
  List<ApiOccurrence>? _occurrences;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOccurrences();
  }

  Future<void> _loadOccurrences() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final occurrences = await _occurrenceService.getMyOccurrences();
      setState(() {
        _occurrences = occurrences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar ocorrências: $e';
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

  OccurrenceStatus _mapStatusFromApi(String status) {
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
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Minhas Ocorrências',
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadOccurrences,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                          _errorMessage!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOccurrences,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : _occurrences == null || _occurrences!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma ocorrência registrada',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Suas ocorrências aparecerão aqui',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _occurrences!.length,
                      itemBuilder: (context, index) {
                        final occurrence = _occurrences![index];
                        return OccurrenceCard(
                          id: occurrence.id,
                          type: _mapTypeFromApi(occurrence.tipo),
                          status: _mapStatusFromApi(occurrence.status ?? 'enviado'),
                          description: occurrence.descricao,
                          date: _formatDate(occurrence.createdAt),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/occurrence/${occurrence.id}',
                            );
                          },
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/new');
          if (result == true && mounted) {
            // Reload occurrences
            _loadOccurrences();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
