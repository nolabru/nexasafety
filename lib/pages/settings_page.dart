import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/user.dart';
import '../core/services/user_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/staggered_animation.dart';
import 'edit_profile_page.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _userService = UserService();
  User? _currentUser;
  bool _isLoading = true;
  bool _pushNotifications = true;
  bool _locationAlerts = true;
  bool _anonymousModeDefault = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadPreferences();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _userService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: 'Erro ao carregar perfil: $e',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _locationAlerts = prefs.getBool('location_alerts') ?? true;
      _anonymousModeDefault = prefs.getBool('anonymous_mode_default') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _navigateToEditProfile() async {
    if (_currentUser == null) return;

    final result = await Navigator.of(context).push<User>(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: _currentUser!),
      ),
    );

    if (result != null) {
      setState(() {
        _currentUser = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Configurações',
        greenBackground: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Profile Header
                StaggeredAnimationItem(
                  index: 0,
                  child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Profile Photo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _currentUser?.fullProfilePhotoUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: _currentUser!.fullProfilePhotoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      _buildDefaultAvatar(),
                                )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User Name
                      Text(
                        _currentUser?.nome ?? 'Usuário',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // User Email
                      Text(
                        _currentUser?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                  ),
                ),

                const SizedBox(height: 20),

                // Perfil Section
                StaggeredAnimationItem(
                  index: 1,
                  child: Column(
                    children: [
                      _SectionHeader(title: 'Perfil'),
                      _SettingsTile(
                  icon: FontAwesomeIcons.userPen,
                  title: 'Editar Perfil',
                  subtitle: 'Alterar nome, email, telefone e foto',
                  onTap: _navigateToEditProfile,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1),

                // Notificações Section
                StaggeredAnimationItem(
                  index: 2,
                  child: Column(
                    children: [
                      _SectionHeader(title: 'Notificações'),
                _SettingsTile(
                  icon: FontAwesomeIcons.bell,
                  title: 'Notificações Push',
                  subtitle: 'Receber alertas de ocorrências',
                  trailing: Switch(
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                      _savePreference('push_notifications', value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                _SettingsTile(
                  icon: FontAwesomeIcons.locationDot,
                  title: 'Alertas de Região',
                  subtitle: 'Notificar sobre ocorrências próximas',
                  trailing: Switch(
                    value: _locationAlerts,
                    onChanged: (value) {
                      setState(() {
                        _locationAlerts = value;
                      });
                      _savePreference('location_alerts', value);
                    },
                    activeColor: AppColors.primary,
                  ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1),

                // Privacidade Section
                StaggeredAnimationItem(
                  index: 3,
                  child: Column(
                    children: [
                      _SectionHeader(title: 'Privacidade'),
                _SettingsTile(
                  icon: FontAwesomeIcons.userSecret,
                  title: 'Modo Anônimo Padrão',
                  subtitle: 'Sempre criar ocorrências anonimamente',
                  trailing: Switch(
                    value: _anonymousModeDefault,
                    onChanged: (value) {
                      setState(() {
                        _anonymousModeDefault = value;
                      });
                      _savePreference('anonymous_mode_default', value);
                    },
                    activeColor: AppColors.primary,
                  ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1),

                // Sobre Section
                StaggeredAnimationItem(
                  index: 4,
                  child: Column(
                    children: [
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
                        const Text(
                          'A segurança começa com informação. Denuncie, acompanhe e receba alertas com o NexaSafety.',
                        ),
                      ],
                    );
                  },
                ),
                _SettingsTile(
                  icon: FontAwesomeIcons.fileLines,
                  title: 'Termos de Uso',
                  subtitle: 'Leia nossos termos e condições',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServicePage(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: FontAwesomeIcons.shieldHalved,
                  title: 'Política de Privacidade',
                  subtitle: 'Como protegemos seus dados',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1),

                // Sair
                const SizedBox(height: 24),
                StaggeredAnimationItem(
                  index: 5,
                  child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sair'),
                          content:
                              const Text('Deseja realmente sair da sua conta?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Clear token
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('access_token');

                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login',
                                  (route) => false,
                                );
                              },
                              child: Text(
                                'Sair',
                                style: TextStyle(
                                  color: AppColors.statusRejeitado,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      size: 18,
                    ),
                    label: const Text(
                      'Sair da Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusRejeitado,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.white,
      child: Icon(
        Icons.person,
        size: 50,
        color: AppColors.primary.withOpacity(0.5),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.5,
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
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FaIcon(icon, size: 20, color: AppColors.primary),
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_right,
                    color: AppColors.textLight,
                    size: 24,
                  )
                : null),
        onTap: onTap,
      ),
    );
  }
}
