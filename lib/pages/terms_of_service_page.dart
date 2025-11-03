import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_appbar.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Termos de Uso',
        greenBackground: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Termos e Condições de Uso',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última atualização: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Aceitação dos Termos',
              'Ao acessar e utilizar o aplicativo NexaSafety, você concorda em cumprir e estar vinculado aos seguintes termos e condições de uso. Se você não concordar com algum destes termos, por favor, não utilize nosso serviço.',
            ),
            _buildSection(
              context,
              '2. Descrição do Serviço',
              'O NexaSafety é uma plataforma de segurança urbana que permite aos cidadãos reportar ocorrências e incidentes às autoridades competentes. O serviço visa melhorar a segurança pública através da colaboração comunitária.',
            ),
            _buildSection(
              context,
              '3. Responsabilidades do Usuário',
              'Você concorda em:\n\n'
                  '• Fornecer informações verdadeiras e precisas\n'
                  '• Não utilizar o serviço para fins ilegais ou maliciosos\n'
                  '• Não fazer denúncias falsas ou enganosas\n'
                  '• Respeitar os direitos de terceiros\n'
                  '• Manter a confidencialidade de suas credenciais de acesso\n'
                  '• Utilizar o aplicativo de forma responsável e ética',
            ),
            _buildSection(
              context,
              '4. Denúncias e Conteúdo',
              'Todas as denúncias submetidas através do aplicativo serão analisadas pelas autoridades competentes. Denúncias falsas ou mal-intencionadas podem resultar em ações legais. O usuário é responsável pelo conteúdo de suas denúncias.',
            ),
            _buildSection(
              context,
              '5. Privacidade e Dados',
              'Seus dados pessoais serão tratados de acordo com nossa Política de Privacidade. Comprometemo-nos a proteger suas informações e utilizá-las apenas para os fins descritos.',
            ),
            _buildSection(
              context,
              '6. Denúncias Anônimas',
              'Embora o aplicativo permita denúncias anônimas, algumas informações técnicas (como localização) podem ser coletadas para validação. A identidade do denunciante será protegida conforme a legislação aplicável.',
            ),
            _buildSection(
              context,
              '7. Disponibilidade do Serviço',
              'Nos esforçamos para manter o serviço disponível 24/7, mas não garantimos que estará livre de interrupções, atrasos ou erros. Reservamo-nos o direito de modificar ou descontinuar o serviço a qualquer momento.',
            ),
            _buildSection(
              context,
              '8. Limitação de Responsabilidade',
              'O NexaSafety não se responsabiliza por:\n\n'
                  '• Ações ou omissões de autoridades públicas\n'
                  '• Tempo de resposta às denúncias\n'
                  '• Resultados específicos de investigações\n'
                  '• Perdas ou danos indiretos',
            ),
            _buildSection(
              context,
              '9. Modificações dos Termos',
              'Reservamo-nos o direito de modificar estes termos a qualquer momento. As alterações entrarão em vigor imediatamente após a publicação. Recomendamos revisar periodicamente esta página.',
            ),
            _buildSection(
              context,
              '10. Lei Aplicável',
              'Estes termos serão regidos e interpretados de acordo com as leis brasileiras. Qualquer disputa será resolvida nos tribunais competentes do Brasil.',
            ),
            _buildSection(
              context,
              '11. Contato',
              'Para questões sobre estes termos, entre em contato:\n\n'
                  'E-mail: suporte@nexasafety.com.br\n'
                  'Telefone: (11) 0000-0000',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ao continuar usando o NexaSafety, você concorda com estes Termos de Uso.',
                      style: Theme.of(context).textTheme.bodySmall,
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
