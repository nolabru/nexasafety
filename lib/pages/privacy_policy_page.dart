import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_appbar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Política de Privacidade',
        greenBackground: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Política de Privacidade',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última atualização: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Introdução',
              'A privacidade dos nossos usuários é fundamental para o NexaSafety. Esta Política de Privacidade descreve como coletamos, usamos, armazenamos e protegemos suas informações pessoais em conformidade com a Lei Geral de Proteção de Dados (LGPD) - Lei nº 13.709/2018.',
            ),
            _buildSection(
              context,
              '2. Dados Coletados',
              'Coletamos as seguintes categorias de dados:\n\n'
                  '• Dados de cadastro: nome, e-mail, telefone\n'
                  '• Dados de localização: coordenadas GPS das denúncias\n'
                  '• Dados de uso: interações com o aplicativo\n'
                  '• Mídia: fotos e vídeos anexados às denúncias\n'
                  '• Dados técnicos: tipo de dispositivo, sistema operacional, IP\n'
                  '• Foto de perfil (opcional)',
            ),
            _buildSection(
              context,
              '3. Finalidade do Tratamento',
              'Utilizamos seus dados para:\n\n'
                  '• Processar e encaminhar denúncias às autoridades\n'
                  '• Melhorar a segurança pública\n'
                  '• Enviar notificações e alertas relevantes\n'
                  '• Validar a autenticidade das denúncias\n'
                  '• Prevenir fraudes e abusos\n'
                  '• Cumprir obrigações legais\n'
                  '• Melhorar nossos serviços',
            ),
            _buildSection(
              context,
              '4. Base Legal',
              'O tratamento dos seus dados é realizado com base em:\n\n'
                  '• Consentimento do titular\n'
                  '• Cumprimento de obrigação legal\n'
                  '• Exercício regular de direitos\n'
                  '• Proteção da vida ou segurança física\n'
                  '• Legítimo interesse do controlador',
            ),
            _buildSection(
              context,
              '5. Compartilhamento de Dados',
              'Seus dados podem ser compartilhados com:\n\n'
                  '• Autoridades públicas competentes (polícia, prefeitura)\n'
                  '• Prestadores de serviço (hospedagem, análise de dados)\n'
                  '• Órgãos reguladores, mediante solicitação legal\n\n'
                  'Não vendemos ou alugamos seus dados pessoais a terceiros.',
            ),
            _buildSection(
              context,
              '6. Denúncias Anônimas',
              'Quando você escolhe fazer uma denúncia anônima:\n\n'
                  '• Seu nome não será divulgado\n'
                  '• Dados mínimos necessários são coletados\n'
                  '• Localização pode ser coletada para validação\n'
                  '• Anonimato é respeitado nos limites da lei',
            ),
            _buildSection(
              context,
              '7. Segurança dos Dados',
              'Implementamos medidas de segurança técnicas e organizacionais:\n\n'
                  '• Criptografia de dados em trânsito e repouso\n'
                  '• Controles de acesso rigorosos\n'
                  '• Monitoramento de segurança 24/7\n'
                  '• Auditorias regulares de segurança\n'
                  '• Treinamento de equipe em proteção de dados',
            ),
            _buildSection(
              context,
              '8. Retenção de Dados',
              'Mantemos seus dados:\n\n'
                  '• Enquanto sua conta estiver ativa\n'
                  '• Pelo tempo necessário para cumprir finalidades legais\n'
                  '• Conforme exigido por obrigações legais\n'
                  '• Denúncias: mínimo de 5 anos para fins estatísticos e legais',
            ),
            _buildSection(
              context,
              '9. Seus Direitos (LGPD)',
              'Você tem direito a:\n\n'
                  '• Confirmação de tratamento de dados\n'
                  '• Acesso aos seus dados\n'
                  '• Correção de dados incompletos ou desatualizados\n'
                  '• Anonimização, bloqueio ou eliminação\n'
                  '• Portabilidade dos dados\n'
                  '• Eliminação dos dados tratados com consentimento\n'
                  '• Informação sobre compartilhamento\n'
                  '• Revogação do consentimento',
            ),
            _buildSection(
              context,
              '10. Cookies e Tecnologias',
              'Utilizamos cookies e tecnologias similares para:\n\n'
                  '• Manter você autenticado\n'
                  '• Lembrar suas preferências\n'
                  '• Analisar o uso do aplicativo\n'
                  '• Melhorar a experiência do usuário',
            ),
            _buildSection(
              context,
              '11. Dados de Menores',
              'O serviço é destinado a maiores de 18 anos. Não coletamos intencionalmente dados de menores sem o consentimento dos responsáveis legais.',
            ),
            _buildSection(
              context,
              '12. Alterações na Política',
              'Podemos atualizar esta política periodicamente. Notificaremos sobre mudanças significativas através do aplicativo ou por e-mail.',
            ),
            _buildSection(
              context,
              '13. Encarregado de Dados (DPO)',
              'Para exercer seus direitos ou esclarecer dúvidas:\n\n'
                  'E-mail: dpo@nexasafety.com.br\n'
                  'Telefone: (11) 0000-0000\n'
                  'Endereço: [Endereço da sede]\n\n'
                  'Tempo de resposta: até 15 dias',
            ),
            _buildSection(
              context,
              '14. Autoridade Nacional',
              'Você pode contatar a Autoridade Nacional de Proteção de Dados (ANPD) para questões não resolvidas:\n\n'
                  'Site: www.gov.br/anpd',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seus dados estão protegidos',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Comprometemo-nos a proteger sua privacidade e utilizar seus dados apenas para melhorar a segurança da sua comunidade.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
