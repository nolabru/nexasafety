import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configurações',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Perfil Section
          _SectionHeader(title: 'Perfil'),
          _SettingsTile(
            icon: FontAwesomeIcons.user,
            title: 'Editar Perfil',
            subtitle: 'Nome, email e foto',
            onTap: () {
              // TODO: Implement edit profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em desenvolvimento')),
              );
            },
          ),
          
          const Divider(height: 1),
          
          // Notificações Section
          _SectionHeader(title: 'Notificações'),
          _SettingsTile(
            icon: FontAwesomeIcons.bell,
            title: 'Notificações Push',
            subtitle: 'Receber alertas de ocorrências',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification toggle
              },
              activeColor: AppColors.primary,
            ),
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.locationDot,
            title: 'Alertas de Região',
            subtitle: 'Notificar sobre ocorrências próximas',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement location alerts toggle
              },
              activeColor: AppColors.primary,
            ),
          ),
          
          const Divider(height: 1),
          
          // Privacidade Section
          _SectionHeader(title: 'Privacidade'),
          _SettingsTile(
            icon: FontAwesomeIcons.lock,
            title: 'Privacidade',
            subtitle: 'Controle de dados e privacidade',
            onTap: () {
              // TODO: Implement privacy settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em desenvolvimento')),
              );
            },
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.userSecret,
            title: 'Modo Anônimo Padrão',
            subtitle: 'Sempre criar ocorrências anonimamente',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Implement anonymous mode toggle
              },
              activeColor: AppColors.primary,
            ),
          ),
          
          const Divider(height: 1),
          
          // Sobre Section
          _SectionHeader(title: 'Sobre'),
          _SettingsTile(
            icon: FontAwesomeIcons.circleInfo,
            title: 'Sobre o App',
            subtitle: 'Versão 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'NexaSafety',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'A segurança começa com informação. Denuncie, acompanhe e receba alertas com o NexaSafety.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              );
            },
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.fileLines,
            title: 'Termos de Uso',
            onTap: () {
              // TODO: Show terms
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em desenvolvimento')),
              );
            },
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.shieldHalved,
            title: 'Política de Privacidade',
            onTap: () {
              // TODO: Show privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em desenvolvimento')),
              );
            },
          ),
          
          const Divider(height: 1),
          
          // Sair
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sair'),
                    content: const Text('Deseja realmente sair da sua conta?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Sair',
                          style: TextStyle(color: AppColors.statusRejeitado),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusRejeitado,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  FaIcon(FontAwesomeIcons.rightFromBracket, size: 18),
                  SizedBox(width: 8),
                  Text('Sair da Conta'),
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall,
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: AppColors.textLight,
                )
              : null),
      onTap: onTap,
    );
  }
}
