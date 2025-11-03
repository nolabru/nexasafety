import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool greenBackground;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.greenBackground = true,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = greenBackground ? AppColors.primary : Colors.white;
    final foregroundColor = greenBackground ? Colors.white : AppColors.primary;

    // Automatically adjust status bar based on background color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            greenBackground ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            greenBackground ? Brightness.dark : Brightness.light,
      ),
    );

    return AppBar(
      title: Text(title),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: foregroundColor,
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: greenBackground ? 0 : 1,
      iconTheme: IconThemeData(color: foregroundColor),
      leading: automaticallyImplyLeading
          ? IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: foregroundColor,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      automaticallyImplyLeading: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
