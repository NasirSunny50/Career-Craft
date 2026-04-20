import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../providers/cv_provider.dart';
import '../services/pdf_service.dart';
import '../templates/template_registry.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  Future<void> _exportPdf(BuildContext context) async {
    final c = context.read<CvController>();
    final doc = PdfService.buildDocument(c.profile, c.templateId);
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          IconButton(
            tooltip: 'Export PDF',
            onPressed: () => _exportPdf(context),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: Consumer<CvController>(
        builder: (context, c, _) {
          return InteractiveViewer(
            minScale: 0.6,
            maxScale: 3.2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: AspectRatio(
                    aspectRatio: 0.707,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: buildTemplatePreview(c.templateId, c.profile),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
