import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/cv_profile.dart';
import '../models/cv_template_meta.dart';
import '../templates/cv_content_helpers.dart';

PdfColor _accentFor(CvTemplateId id) {
  switch (id) {
    case CvTemplateId.auroraAscent:
      return PdfColor.fromInt(0xFF6366F1);
    case CvTemplateId.obsidianForge:
      return PdfColor.fromInt(0xFF22D3EE);
    case CvTemplateId.crimsonMeridian:
      return PdfColor.fromInt(0xFFBE123C);
    case CvTemplateId.sapphireScholar:
      return PdfColor.fromInt(0xFF2563EB);
    case CvTemplateId.goldenEpoch:
      return PdfColor.fromInt(0xFFB45309);
  }
}

class PdfService {
  static pw.Document buildDocument(CvProfile profile, CvTemplateId templateId) {
    final meta = metaFor(templateId);
    final accent = _accentFor(templateId);
    final base = pw.Font.helvetica();
    final bold = pw.Font.helveticaBold();

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: base, bold: bold),
        build: (context) {
          final blocks = <pw.Widget>[
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: accent,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    profile.fullName,
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 22,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    profile.title,
                    style: pw.TextStyle(
                      font: base,
                      fontSize: 11,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  if (displayContactLine(profile).isNotEmpty)
                    pw.Text(
                      displayContactLine(profile),
                      style: pw.TextStyle(
                        font: base,
                        fontSize: 9,
                        color: PdfColors.white,
                      ),
                    ),
                  if (displaySocialLine(profile).isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      displaySocialLine(profile),
                      style: pw.TextStyle(
                        font: base,
                        fontSize: 8.5,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 14),
            pw.Text(
              '${meta.name} · Career Craft',
              style: pw.TextStyle(
                font: bold,
                fontSize: 10,
                letterSpacing: 1.1,
                color: accent,
              ),
            ),
            pw.SizedBox(height: 8),
            ..._pdfSectionBlocks(profile, base, bold, accent),
          ];
          return blocks;
        },
      ),
    );

    return doc;
  }
}

List<pw.Widget> _pdfSectionBlocks(
  CvProfile profile,
  pw.Font base,
  pw.Font bold,
  PdfColor accent,
) {
  final out = <pw.Widget>[];
  for (final slot in profile.sectionOrder) {
    if (!slotShouldRender(profile, slot)) continue;
    out.add(
      pw.Text(
        effectiveSectionTitle(slot).toUpperCase(),
        style: pw.TextStyle(
          font: bold,
          fontSize: 10,
          letterSpacing: 1.2,
          color: accent,
        ),
      ),
    );
    out.add(pw.SizedBox(height: 6));
    out.addAll(_pdfSlotBody(profile, slot, base, bold));
    out.add(pw.SizedBox(height: 12));
  }
  return out;
}

List<pw.Widget> _pdfSlotBody(
  CvProfile profile,
  ResumeSectionSlot slot,
  pw.Font base,
  pw.Font bold,
) {
  final out = <pw.Widget>[];
  switch (slot.kind) {
    case ResumeSectionKind.summary:
      out.add(
        pw.Text(
          profile.summary,
          style: pw.TextStyle(
            font: base,
            fontSize: 10,
            lineSpacing: 1.35,
            color: PdfColors.grey800,
          ),
        ),
      );
      break;
    case ResumeSectionKind.experience:
      for (final e in profile.experience) {
        if (!experienceEntryHasContent(e)) continue;
        final role = e.role.trim();
        final company = e.company.trim();
        final period = e.period.trim();
        if (role.isNotEmpty) {
          out.add(
            pw.Text(role, style: pw.TextStyle(font: bold, fontSize: 11, color: PdfColors.grey900)),
          );
          if (company.isNotEmpty) {
            out.add(
              pw.Text(company, style: pw.TextStyle(font: base, fontSize: 9.5, color: PdfColors.grey700)),
            );
          }
          if (period.isNotEmpty) {
            out.add(
              pw.Text(period, style: pw.TextStyle(font: base, fontSize: 9.5, color: PdfColors.grey600)),
            );
          }
        } else if (company.isNotEmpty) {
          out.add(
            pw.Text(company, style: pw.TextStyle(font: bold, fontSize: 11, color: PdfColors.grey900)),
          );
          if (period.isNotEmpty) {
            out.add(
              pw.Text(period, style: pw.TextStyle(font: base, fontSize: 9.5, color: PdfColors.grey600)),
            );
          }
        } else if (period.isNotEmpty) {
          out.add(
            pw.Text(period, style: pw.TextStyle(font: base, fontSize: 9.5, color: PdfColors.grey600)),
          );
        }
        for (final b in nonEmptyBullets(e)) {
          out.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, top: 2),
              child: pw.Text(
                '• $b',
                style: pw.TextStyle(
                  font: base,
                  fontSize: 10,
                  lineSpacing: 1.35,
                  color: PdfColors.grey800,
                ),
              ),
            ),
          );
        }
        out.add(pw.SizedBox(height: 8));
      }
      break;
    case ResumeSectionKind.education:
      for (final ed in profile.education) {
        if (!educationEntryHasContent(ed)) continue;
        final deg = ed.degree.trim();
        final inst = ed.institution.trim();
        final per = ed.period.trim();
        if (deg.isNotEmpty) {
          out.add(pw.Text(deg, style: pw.TextStyle(font: bold, fontSize: 10.5, color: PdfColors.grey900)));
          final line2 = [inst, per].where((s) => s.isNotEmpty).join(' · ');
          if (line2.isNotEmpty) {
            out.add(pw.Text(line2, style: pw.TextStyle(font: base, fontSize: 9.5, color: PdfColors.grey700)));
          }
        } else if (inst.isNotEmpty) {
          out.add(pw.Text(inst, style: pw.TextStyle(font: bold, fontSize: 10.5, color: PdfColors.grey900)));
          if (per.isNotEmpty) {
            out.add(pw.Text(per, style: pw.TextStyle(font: base, fontSize: 9.5, color: PdfColors.grey700)));
          }
        } else if (per.isNotEmpty) {
          out.add(pw.Text(per, style: pw.TextStyle(font: bold, fontSize: 10.5, color: PdfColors.grey900)));
        }
        if (ed.cgpa.trim().isNotEmpty) {
          out.add(pw.Text('CGPA: ${ed.cgpa.trim()}', style: pw.TextStyle(font: base, fontSize: 9.5, color: PdfColors.grey700)));
        }
        if (ed.detail.trim().isNotEmpty) {
          out.add(
            pw.Text(
              ed.detail,
              style: pw.TextStyle(font: base, fontSize: 10, lineSpacing: 1.35, color: PdfColors.grey800),
            ),
          );
        }
        out.add(pw.SizedBox(height: 6));
      }
      break;
    case ResumeSectionKind.skills:
      if (mergedTechnical(profile).isNotEmpty) {
        out.add(pw.Text('Technical', style: pw.TextStyle(font: bold, fontSize: 9.5, color: PdfColors.grey800)));
        out.add(pw.Text(mergedTechnical(profile).join(', '), style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800)));
        out.add(pw.SizedBox(height: 6));
      }
      if (mergedTools(profile).isNotEmpty) {
        out.add(pw.Text('Tools', style: pw.TextStyle(font: bold, fontSize: 9.5, color: PdfColors.grey800)));
        out.add(pw.Text(mergedTools(profile).join(', '), style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800)));
        out.add(pw.SizedBox(height: 6));
      }
      if (mergedSoft(profile).isNotEmpty) {
        out.add(pw.Text('Soft skills', style: pw.TextStyle(font: bold, fontSize: 9.5, color: PdfColors.grey800)));
        out.add(pw.Text(mergedSoft(profile).join(', '), style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800)));
      }
      break;
    case ResumeSectionKind.projects:
      for (final pr in profile.projects) {
        if (!projectEntryHasContent(pr)) continue;
        out.add(pw.Text(pr.name.trim().isNotEmpty ? pr.name : 'Project', style: pw.TextStyle(font: bold, fontSize: 10.5, color: PdfColors.grey900)));
        if (pr.techStack.trim().isNotEmpty) {
          out.add(pw.Text(pr.techStack, style: pw.TextStyle(font: base, fontSize: 9.5, color: PdfColors.grey700)));
        }
        if (pr.description.trim().isNotEmpty) {
          out.add(pw.Text(pr.description, style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800)));
        }
        if (pr.link.trim().isNotEmpty) {
          out.add(pw.Text(pr.link, style: pw.TextStyle(font: base, fontSize: 9.5, color: PdfColors.grey700)));
        }
        out.add(pw.SizedBox(height: 8));
      }
      break;
    case ResumeSectionKind.certifications:
      for (final c in profile.certifications) {
        if (!certEntryHasContent(c)) continue;
        out.add(pw.Text(c.name.trim().isNotEmpty ? c.name : 'Certification', style: pw.TextStyle(font: bold, fontSize: 10.5, color: PdfColors.grey900)));
        final sub = [c.issuer, c.year].where((s) => s.trim().isNotEmpty).join(' · ');
        if (sub.isNotEmpty) {
          out.add(pw.Text(sub, style: pw.TextStyle(font: base, fontSize: 9.5, color: PdfColors.grey700)));
        }
        if (c.detail.trim().isNotEmpty) {
          out.add(pw.Text(c.detail, style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800)));
        }
        out.add(pw.SizedBox(height: 6));
      }
      break;
    case ResumeSectionKind.achievements:
      for (final a in profile.achievements) {
        if (a.trim().isEmpty) continue;
        out.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(
              '• $a',
              style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800),
            ),
          ),
        );
      }
      break;
    case ResumeSectionKind.languages:
      for (final l in profile.languages) {
        if (l.name.trim().isEmpty) continue;
        out.add(
          pw.Text(
            l.level.isEmpty ? l.name.trim() : '${l.name.trim()} (${l.level})',
            style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800),
          ),
        );
      }
      break;
    case ResumeSectionKind.interests:
      out.add(pw.Text(profile.interests, style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800)));
      break;
    case ResumeSectionKind.volunteer:
      out.add(pw.Text(profile.volunteer, style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800)));
      break;
    case ResumeSectionKind.publications:
      out.add(pw.Text(profile.publications, style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800)));
      break;
    case ResumeSectionKind.custom:
      out.add(pw.Text(slot.customBody, style: pw.TextStyle(font: base, fontSize: 10, color: PdfColors.grey800)));
      break;
  }
  return out;
}
