import 'package:uuid/uuid.dart';

class ExperienceEntry {
  ExperienceEntry({
    String? id,
    this.company = '',
    this.role = '',
    this.period = '',
    List<String>? bullets,
  })  : id = id ?? const Uuid().v4(),
        bullets = bullets ?? <String>[];

  final String id;
  String company;
  String role;
  String period;
  List<String> bullets;

  ExperienceEntry copyWith({
    String? company,
    String? role,
    String? period,
    List<String>? bullets,
  }) {
    return ExperienceEntry(
      id: id,
      company: company ?? this.company,
      role: role ?? this.role,
      period: period ?? this.period,
      bullets: bullets != null ? List<String>.from(bullets) : List<String>.from(this.bullets),
    );
  }
}

class EducationEntry {
  EducationEntry({
    String? id,
    this.institution = '',
    this.degree = '',
    this.period = '',
    this.detail = '',
    this.cgpa = '',
  }) : id = id ?? const Uuid().v4();

  final String id;
  String institution;
  String degree;
  String period;
  String detail;
  String cgpa;
}

class LanguageEntry {
  LanguageEntry({
    String? id,
    this.name = '',
    this.level = '',
  }) : id = id ?? const Uuid().v4();

  final String id;
  String name;
  String level;
}

class ProjectEntry {
  ProjectEntry({
    String? id,
    this.name = '',
    this.techStack = '',
    this.description = '',
    this.link = '',
  }) : id = id ?? const Uuid().v4();

  final String id;
  String name;
  String techStack;
  String description;
  String link;
}

class CertificationEntry {
  CertificationEntry({
    String? id,
    this.name = '',
    this.issuer = '',
    this.year = '',
    this.detail = '',
  }) : id = id ?? const Uuid().v4();

  final String id;
  String name;
  String issuer;
  String year;
  String detail;
}

/// Built-in section types. Users can add/remove/reorder/rename in the editor.
enum ResumeSectionKind {
  summary,
  experience,
  education,
  skills,
  projects,
  certifications,
  achievements,
  languages,
  interests,
  volunteer,
  publications,
  custom,
}

class ResumeSectionSlot {
  ResumeSectionSlot({
    required this.id,
    required this.kind,
    this.titleOverride = '',
    this.customBody = '',
  });

  final String id;
  final ResumeSectionKind kind;
  String titleOverride;
  String customBody;

  ResumeSectionSlot copyWith({
    String? titleOverride,
    String? customBody,
  }) {
    return ResumeSectionSlot(
      id: id,
      kind: kind,
      titleOverride: titleOverride ?? this.titleOverride,
      customBody: customBody ?? this.customBody,
    );
  }
}

String _sid() => const Uuid().v4();

/// Default labels when `titleOverride` is empty.
const Map<ResumeSectionKind, String> kDefaultSectionTitles = {
  ResumeSectionKind.summary: 'Professional Summary / Objective',
  ResumeSectionKind.experience: 'Work Experience',
  ResumeSectionKind.education: 'Education',
  ResumeSectionKind.skills: 'Skills',
  ResumeSectionKind.projects: 'Projects',
  ResumeSectionKind.certifications: 'Certifications',
  ResumeSectionKind.achievements: 'Achievements / Awards',
  ResumeSectionKind.languages: 'Languages',
  ResumeSectionKind.interests: 'Interests',
  ResumeSectionKind.volunteer: 'Volunteer Experience',
  ResumeSectionKind.publications: 'Publications',
  ResumeSectionKind.custom: 'Custom',
};

List<ResumeSectionSlot> defaultSectionOrder() => [
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.summary),
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.experience),
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.education),
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.skills),
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.projects),
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.certifications),
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.achievements),
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.languages),
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.interests),
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.volunteer),
      ResumeSectionSlot(id: _sid(), kind: ResumeSectionKind.publications),
    ];

class CvProfile {
  CvProfile({
    this.fullName = '',
    this.title = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.summary = '',
    this.linkedin = '',
    this.portfolio = '',
    this.github = '',
    List<ExperienceEntry>? experience,
    List<EducationEntry>? education,
    List<String>? skills,
    List<String>? technicalSkills,
    List<String>? toolSkills,
    List<String>? softSkills,
    List<ProjectEntry>? projects,
    List<CertificationEntry>? certifications,
    List<String>? achievements,
    List<LanguageEntry>? languages,
    this.interests = '',
    this.volunteer = '',
    this.publications = '',
    List<ResumeSectionSlot>? sectionOrder,
  })  : experience = experience ?? [],
        education = education ?? [],
        skills = skills ?? [],
        technicalSkills = technicalSkills ?? [],
        toolSkills = toolSkills ?? [],
        softSkills = softSkills ?? [],
        projects = projects ?? [],
        certifications = certifications ?? [],
        achievements = achievements ?? [],
        languages = languages ?? [],
        sectionOrder = sectionOrder ?? defaultSectionOrder();

  String fullName;
  String title;
  String email;
  String phone;
  String location;
  String summary;
  String linkedin;
  String portfolio;
  String github;

  List<ExperienceEntry> experience;
  List<EducationEntry> education;

  /// Legacy flat list; merged into technical for display when the three ATS lists are empty.
  List<String> skills;
  List<String> technicalSkills;
  List<String> toolSkills;
  List<String> softSkills;

  List<ProjectEntry> projects;
  List<CertificationEntry> certifications;
  List<String> achievements;
  List<LanguageEntry> languages;

  String interests;
  String volunteer;
  String publications;

  List<ResumeSectionSlot> sectionOrder;

  /// Move legacy flat [skills] into [technicalSkills] when the latter is empty.
  void normalizeLegacySkills() {
    final tech =
        technicalSkills.map((s) => s.trim()).where((s) => s.isNotEmpty);
    if (tech.isNotEmpty) return;
    final legacy =
        skills.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (legacy.isEmpty) return;
    technicalSkills = legacy;
    skills.clear();
  }

  CvProfile copy() {
    return CvProfile(
      fullName: fullName,
      title: title,
      email: email,
      phone: phone,
      location: location,
      summary: summary,
      linkedin: linkedin,
      portfolio: portfolio,
      github: github,
      experience: experience
          .map((e) => ExperienceEntry(
                id: e.id,
                company: e.company,
                role: e.role,
                period: e.period,
                bullets: List<String>.from(e.bullets),
              ))
          .toList(),
      education: education
          .map((e) => EducationEntry(
                id: e.id,
                institution: e.institution,
                degree: e.degree,
                period: e.period,
                detail: e.detail,
                cgpa: e.cgpa,
              ))
          .toList(),
      skills: List<String>.from(skills),
      technicalSkills: List<String>.from(technicalSkills),
      toolSkills: List<String>.from(toolSkills),
      softSkills: List<String>.from(softSkills),
      projects: projects
          .map((e) => ProjectEntry(
                id: e.id,
                name: e.name,
                techStack: e.techStack,
                description: e.description,
                link: e.link,
              ))
          .toList(),
      certifications: certifications
          .map((e) => CertificationEntry(
                id: e.id,
                name: e.name,
                issuer: e.issuer,
                year: e.year,
                detail: e.detail,
              ))
          .toList(),
      achievements: List<String>.from(achievements),
      languages: languages
          .map((e) => LanguageEntry(id: e.id, name: e.name, level: e.level))
          .toList(),
      interests: interests,
      volunteer: volunteer,
      publications: publications,
      sectionOrder: sectionOrder
          .map(
            (s) => ResumeSectionSlot(
              id: s.id,
              kind: s.kind,
              titleOverride: s.titleOverride,
              customBody: s.customBody,
            ),
          )
          .toList(),
    );
  }
}
