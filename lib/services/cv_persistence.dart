import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cv_profile.dart';
import '../models/cv_template_meta.dart';

const _kProfileJson = 'career_craft_cv_profile_v1';
const _kTemplateId = 'career_craft_cv_template_v1';

Map<String, dynamic> _profileToJson(CvProfile p) {
  return {
    'fullName': p.fullName,
    'title': p.title,
    'email': p.email,
    'phone': p.phone,
    'location': p.location,
    'summary': p.summary,
    'linkedin': p.linkedin,
    'portfolio': p.portfolio,
    'github': p.github,
    'experience': p.experience.map(_experienceToJson).toList(),
    'education': p.education.map(_educationToJson).toList(),
    'skills': p.skills,
    'technicalSkills': p.technicalSkills,
    'toolSkills': p.toolSkills,
    'softSkills': p.softSkills,
    'projects': p.projects.map(_projectToJson).toList(),
    'certifications': p.certifications.map(_certToJson).toList(),
    'achievements': p.achievements,
    'languages': p.languages.map(_languageToJson).toList(),
    'interests': p.interests,
    'volunteer': p.volunteer,
    'publications': p.publications,
    'sectionOrder': p.sectionOrder.map(_sectionToJson).toList(),
  };
}

Map<String, dynamic> _experienceToJson(ExperienceEntry e) => {
      'id': e.id,
      'company': e.company,
      'role': e.role,
      'period': e.period,
      'bullets': e.bullets,
    };

Map<String, dynamic> _educationToJson(EducationEntry e) => {
      'id': e.id,
      'institution': e.institution,
      'degree': e.degree,
      'period': e.period,
      'detail': e.detail,
      'cgpa': e.cgpa,
    };

Map<String, dynamic> _projectToJson(ProjectEntry e) => {
      'id': e.id,
      'name': e.name,
      'techStack': e.techStack,
      'description': e.description,
      'link': e.link,
    };

Map<String, dynamic> _certToJson(CertificationEntry e) => {
      'id': e.id,
      'name': e.name,
      'issuer': e.issuer,
      'year': e.year,
      'detail': e.detail,
    };

Map<String, dynamic> _languageToJson(LanguageEntry e) => {
      'id': e.id,
      'name': e.name,
      'level': e.level,
    };

Map<String, dynamic> _sectionToJson(ResumeSectionSlot s) => {
      'id': s.id,
      'kind': s.kind.name,
      'titleOverride': s.titleOverride,
      'customBody': s.customBody,
    };

ExperienceEntry _experienceFromJson(Map<String, dynamic> m) {
  return ExperienceEntry(
    id: m['id'] as String?,
    company: m['company'] as String? ?? '',
    role: m['role'] as String? ?? '',
    period: m['period'] as String? ?? '',
    bullets: (m['bullets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[],
  );
}

EducationEntry _educationFromJson(Map<String, dynamic> m) {
  return EducationEntry(
    id: m['id'] as String?,
    institution: m['institution'] as String? ?? '',
    degree: m['degree'] as String? ?? '',
    period: m['period'] as String? ?? '',
    detail: m['detail'] as String? ?? '',
    cgpa: m['cgpa'] as String? ?? '',
  );
}

ProjectEntry _projectFromJson(Map<String, dynamic> m) {
  return ProjectEntry(
    id: m['id'] as String?,
    name: m['name'] as String? ?? '',
    techStack: m['techStack'] as String? ?? '',
    description: m['description'] as String? ?? '',
    link: m['link'] as String? ?? '',
  );
}

CertificationEntry _certFromJson(Map<String, dynamic> m) {
  return CertificationEntry(
    id: m['id'] as String?,
    name: m['name'] as String? ?? '',
    issuer: m['issuer'] as String? ?? '',
    year: m['year'] as String? ?? '',
    detail: m['detail'] as String? ?? '',
  );
}

LanguageEntry _languageFromJson(Map<String, dynamic> m) {
  return LanguageEntry(
    id: m['id'] as String?,
    name: m['name'] as String? ?? '',
    level: m['level'] as String? ?? '',
  );
}

ResumeSectionKind _parseKind(String? name) {
  if (name == null || name.isEmpty) return ResumeSectionKind.custom;
  for (final k in ResumeSectionKind.values) {
    if (k.name == name) return k;
  }
  return ResumeSectionKind.custom;
}

ResumeSectionSlot _sectionFromJson(Map<String, dynamic> m) {
  return ResumeSectionSlot(
    id: m['id'] as String? ?? '',
    kind: _parseKind(m['kind'] as String?),
    titleOverride: m['titleOverride'] as String? ?? '',
    customBody: m['customBody'] as String? ?? '',
  );
}

CvProfile _profileFromJson(Map<String, dynamic> j) {
  List<ResumeSectionSlot>? sections;
  final sectionRaw = j['sectionOrder'] as List<dynamic>?;
  if (sectionRaw != null && sectionRaw.isNotEmpty) {
    final parsed = sectionRaw
        .whereType<Map<String, dynamic>>()
        .map(_sectionFromJson)
        .where((s) => s.id.isNotEmpty)
        .toList();
    if (parsed.isNotEmpty) sections = parsed;
  }

  return CvProfile(
    fullName: j['fullName'] as String? ?? '',
    title: j['title'] as String? ?? '',
    email: j['email'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    location: j['location'] as String? ?? '',
    summary: j['summary'] as String? ?? '',
    linkedin: j['linkedin'] as String? ?? '',
    portfolio: j['portfolio'] as String? ?? '',
    github: j['github'] as String? ?? '',
    experience: (j['experience'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(_experienceFromJson)
            .toList() ??
        [],
    education: (j['education'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(_educationFromJson)
            .toList() ??
        [],
    skills: (j['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    technicalSkills:
        (j['technicalSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    toolSkills: (j['toolSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    softSkills: (j['softSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    projects: (j['projects'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(_projectFromJson)
            .toList() ??
        [],
    certifications: (j['certifications'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(_certFromJson)
            .toList() ??
        [],
    achievements:
        (j['achievements'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    languages: (j['languages'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(_languageFromJson)
            .toList() ??
        [],
    interests: j['interests'] as String? ?? '',
    volunteer: j['volunteer'] as String? ?? '',
    publications: j['publications'] as String? ?? '',
    sectionOrder: sections,
  );
}

CvTemplateId _parseTemplate(String? raw) {
  if (raw == null || raw.isEmpty) return CvTemplateId.auroraAscent;
  for (final t in CvTemplateId.values) {
    if (t.name == raw) return t;
  }
  return CvTemplateId.auroraAscent;
}

/// Loads saved CV and template; falls back to defaults if missing or corrupt.
Future<({CvProfile profile, CvTemplateId template})> loadCvSnapshot() async {
  final prefs = await SharedPreferences.getInstance();
  final template = _parseTemplate(prefs.getString(_kTemplateId));

  final raw = prefs.getString(_kProfileJson);
  if (raw == null || raw.isEmpty) {
    final p = CvProfile();
    p.normalizeLegacySkills();
    return (profile: p, template: template);
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      final p = CvProfile();
      p.normalizeLegacySkills();
      return (profile: p, template: template);
    }
    final p = _profileFromJson(decoded);
    p.normalizeLegacySkills();
    return (profile: p, template: template);
  } catch (_) {
    final p = CvProfile();
    p.normalizeLegacySkills();
    return (profile: p, template: template);
  }
}

Future<void> persistCvSnapshot(CvProfile profile, CvTemplateId template) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kTemplateId, template.name);
  await prefs.setString(_kProfileJson, jsonEncode(_profileToJson(profile)));
}
