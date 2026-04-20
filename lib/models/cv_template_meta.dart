import 'package:flutter/material.dart';

enum CvTemplateId {
  auroraAscent,
  obsidianForge,
  crimsonMeridian,
  sapphireScholar,
  goldenEpoch,
}

class CvTemplateMeta {
  const CvTemplateMeta({
    required this.id,
    required this.name,
    required this.tagline,
    required this.accentColor,
    required this.previewGradient,
  });

  final CvTemplateId id;
  final String name;
  final String tagline;
  final Color accentColor;
  final List<Color> previewGradient;
}

const List<CvTemplateMeta> kTemplates = [
  CvTemplateMeta(
    id: CvTemplateId.auroraAscent,
    name: 'Aurora Ascent',
    tagline: 'Soft gradients & airy hierarchy',
    accentColor: Color(0xFF6366F1),
    previewGradient: [Color(0xFF312E81), Color(0xFF818CF8), Color(0xFFE0E7FF)],
  ),
  CvTemplateMeta(
    id: CvTemplateId.obsidianForge,
    name: 'Obsidian Forge',
    tagline: 'Bold split layout for tech & product',
    accentColor: Color(0xFF22D3EE),
    previewGradient: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
  ),
  CvTemplateMeta(
    id: CvTemplateId.crimsonMeridian,
    name: 'Crimson Meridian',
    tagline: 'Executive stripe & confident type',
    accentColor: Color(0xFFBE123C),
    previewGradient: [Color(0xFF881337), Color(0xFFE11D48), Color(0xFFFFF1F2)],
  ),
  CvTemplateMeta(
    id: CvTemplateId.sapphireScholar,
    name: 'Sapphire Scholar',
    tagline: 'Classic academic two-column rhythm',
    accentColor: Color(0xFF2563EB),
    previewGradient: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFFEFF6FF)],
  ),
  CvTemplateMeta(
    id: CvTemplateId.goldenEpoch,
    name: 'Golden Epoch',
    tagline: 'Editorial luxury on warm paper',
    accentColor: Color(0xFFB45309),
    previewGradient: [Color(0xFF78350F), Color(0xFFD97706), Color(0xFFFFFBEB)],
  ),
];

CvTemplateMeta metaFor(CvTemplateId id) =>
    kTemplates.firstWhere((t) => t.id == id);
