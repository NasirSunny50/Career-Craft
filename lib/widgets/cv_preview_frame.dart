import 'package:flutter/material.dart';

import '../models/cv_profile.dart';
import '../models/cv_template_meta.dart';
import '../templates/template_registry.dart';

/// A4 preview scaled to fit width; tap opens full preview route separately.
class CvPreviewFrame extends StatelessWidget {
  const CvPreviewFrame({
    super.key,
    required this.profile,
    required this.templateId,
    this.minHeight = 420,
  });

  final CvProfile profile;
  final CvTemplateId templateId;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = (w / 0.707).clamp(minHeight, 900.0);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 420,
                height: 420 / 0.707,
                child: buildTemplatePreview(templateId, profile),
              ),
            ),
          ),
        );
      },
    );
  }
}
