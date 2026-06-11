import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../models/enums/severity_level.dart';

class UrgencyIndicator extends StatelessWidget {
  final SeverityLevel severity;

  const UrgencyIndicator({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index <= severity.index;
        return Container(
          width: 24,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive
                ? severity.color
                : AppColors.divider,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}