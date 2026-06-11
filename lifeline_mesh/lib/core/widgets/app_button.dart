import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool disabled;
  final ButtonType type;
  final double? width;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.disabled = false,
    this.type = ButtonType.primary,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading;

    Color backgroundColor;
    Color foregroundColor;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = AppColors.trustBlue;
        foregroundColor = Colors.white;
        break;
      case ButtonType.secondary:
        backgroundColor = Colors.white;
        foregroundColor = AppColors.textPrimary;
        break;
      case ButtonType.emergency:
        backgroundColor = AppColors.emergencyRed;
        foregroundColor = Colors.white;
        break;
      case ButtonType.success:
        backgroundColor = AppColors.successGreen;
        foregroundColor = Colors.white;
        break;
      case ButtonType.danger:
        backgroundColor = AppColors.emergencyRed;
        foregroundColor = Colors.white;
        break;
      case ButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.trustBlue;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: type == ButtonType.secondary
                ? BorderSide(color: AppColors.divider)
                : BorderSide.none,
          ),
          elevation: type == ButtonType.text ? 0 : 1,
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDisabled
                          ? foregroundColor.withValues(alpha: 0.5)
                          : foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

enum ButtonType { primary, secondary, emergency, success, danger, text }