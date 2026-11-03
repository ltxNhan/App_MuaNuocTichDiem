import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomToast {
  CustomToast._();

  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
      backgroundColor: const Color(0xFF1E2D24),
      borderColor: AppColors.success.withOpacity(0.5),
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.error_rounded,
      iconColor: AppColors.error,
      backgroundColor: const Color(0xFF2D1E1E),
      borderColor: AppColors.error.withOpacity(0.5),
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      icon: Icons.info_rounded,
      iconColor: AppColors.primaryGold,
      backgroundColor: const Color(0xFF26221A),
      borderColor: AppColors.primaryGold.withOpacity(0.5),
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
