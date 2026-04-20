import 'package:flutter/material.dart';

import '../models/cv_profile.dart';

List<String> nonEmptyBullets(ExperienceEntry e) =>
    e.bullets.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

Widget sectionTitle(String text, {TextStyle? style, Color? color}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: style ??
          TextStyle(
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
            color: color ?? const Color(0xFF64748B),
          ),
    ),
  );
}

/// Email, phone, location — only filled values.
String displayContactLine(CvProfile p) {
  final parts = <String>[];
  if (p.email.trim().isNotEmpty) parts.add(p.email.trim());
  if (p.phone.trim().isNotEmpty) parts.add(p.phone.trim());
  if (p.location.trim().isNotEmpty) parts.add(p.location.trim());
  return parts.join(' · ');
}

/// LinkedIn, portfolio, GitHub — only filled values.
String displaySocialLine(CvProfile p) {
  final parts = <String>[];
  if (p.linkedin.trim().isNotEmpty) parts.add(p.linkedin.trim());
  if (p.portfolio.trim().isNotEmpty) parts.add(p.portfolio.trim());
  if (p.github.trim().isNotEmpty) parts.add(p.github.trim());
  return parts.join(' · ');
}

String effectiveSectionTitle(ResumeSectionSlot s) {
  final t = s.titleOverride.trim();
  if (t.isNotEmpty) return t;
  if (s.kind == ResumeSectionKind.custom) {
    return 'Custom';
  }
  return kDefaultSectionTitles[s.kind] ?? 'Section';
}

/// Legacy `skills` feed technical when the three ATS lists are empty.
List<String> mergedTechnical(CvProfile p) {
  final m = p.technicalSkills.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  if (m.isNotEmpty) return m;
  return p.skills.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
}

List<String> mergedTools(CvProfile p) =>
    p.toolSkills.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

List<String> mergedSoft(CvProfile p) =>
    p.softSkills.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

bool hasAnySkillsContent(CvProfile p) =>
    mergedTechnical(p).isNotEmpty || mergedTools(p).isNotEmpty || mergedSoft(p).isNotEmpty;

bool experienceEntryHasContent(ExperienceEntry e) {
  if (e.role.trim().isNotEmpty || e.company.trim().isNotEmpty || e.period.trim().isNotEmpty) {
    return true;
  }
  return nonEmptyBullets(e).isNotEmpty;
}

bool educationEntryHasContent(EducationEntry e) =>
    e.institution.trim().isNotEmpty ||
    e.degree.trim().isNotEmpty ||
    e.period.trim().isNotEmpty ||
    e.detail.trim().isNotEmpty ||
    e.cgpa.trim().isNotEmpty;

bool projectEntryHasContent(ProjectEntry e) =>
    e.name.trim().isNotEmpty ||
    e.techStack.trim().isNotEmpty ||
    e.description.trim().isNotEmpty ||
    e.link.trim().isNotEmpty;

bool certEntryHasContent(CertificationEntry e) =>
    e.name.trim().isNotEmpty ||
    e.issuer.trim().isNotEmpty ||
    e.year.trim().isNotEmpty ||
    e.detail.trim().isNotEmpty;

/// Whether a section should appear on the CV (only user-written content).
bool sectionKindHasContent(CvProfile p, ResumeSectionKind k) {
  switch (k) {
    case ResumeSectionKind.summary:
      return p.summary.trim().isNotEmpty;
    case ResumeSectionKind.experience:
      return p.experience.any(experienceEntryHasContent);
    case ResumeSectionKind.education:
      return p.education.any(educationEntryHasContent);
    case ResumeSectionKind.skills:
      return hasAnySkillsContent(p);
    case ResumeSectionKind.projects:
      return p.projects.any(projectEntryHasContent);
    case ResumeSectionKind.certifications:
      return p.certifications.any(certEntryHasContent);
    case ResumeSectionKind.achievements:
      return p.achievements.any((a) => a.trim().isNotEmpty);
    case ResumeSectionKind.languages:
      return p.languages.any((l) => l.name.trim().isNotEmpty);
    case ResumeSectionKind.interests:
      return p.interests.trim().isNotEmpty;
    case ResumeSectionKind.volunteer:
      return p.volunteer.trim().isNotEmpty;
    case ResumeSectionKind.publications:
      return p.publications.trim().isNotEmpty;
    case ResumeSectionKind.custom:
      return false;
  }
}

bool customSectionHasContent(ResumeSectionSlot s) =>
    s.kind == ResumeSectionKind.custom && s.customBody.trim().isNotEmpty;

bool slotShouldRender(CvProfile p, ResumeSectionSlot s) {
  if (s.kind == ResumeSectionKind.custom) {
    return customSectionHasContent(s);
  }
  return sectionKindHasContent(p, s.kind);
}
