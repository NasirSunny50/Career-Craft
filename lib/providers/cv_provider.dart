import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cv_profile.dart';
import '../models/cv_template_meta.dart';
import '../services/cv_persistence.dart';

class CvController extends ChangeNotifier {
  CvController({
    CvProfile? profile,
    CvTemplateId template = CvTemplateId.auroraAscent,
  })  : _profile = profile ?? CvProfile(),
        _template = template {
    _profile.normalizeLegacySkills();
  }

  Timer? _saveDebounce;

  static const _saveDelay = Duration(milliseconds: 350);

  CvProfile _profile;
  CvTemplateId _template;

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(_saveDelay, () {
      persistCvSnapshot(_profile, _template);
    });
  }

  /// Writes immediately (e.g. app going to background). Cancels pending debounced save.
  void flushPersistence() {
    _saveDebounce?.cancel();
    unawaited(persistCvSnapshot(_profile, _template));
  }

  void _changed() {
    notifyListeners();
    _scheduleSave();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    unawaited(persistCvSnapshot(_profile, _template));
    super.dispose();
  }

  CvProfile get profile => _profile;
  CvTemplateId get templateId => _template;

  void selectTemplate(CvTemplateId id) {
    _template = id;
    _changed();
  }

  void replaceProfile(CvProfile next) {
    _profile = next;
    _profile.normalizeLegacySkills();
    _changed();
  }

  void updateBasics({
    String? fullName,
    String? title,
    String? email,
    String? phone,
    String? location,
    String? summary,
    String? linkedin,
    String? portfolio,
    String? github,
  }) {
    if (fullName != null) _profile.fullName = fullName;
    if (title != null) _profile.title = title;
    if (email != null) _profile.email = email;
    if (phone != null) _profile.phone = phone;
    if (location != null) _profile.location = location;
    if (summary != null) _profile.summary = summary;
    if (linkedin != null) _profile.linkedin = linkedin;
    if (portfolio != null) _profile.portfolio = portfolio;
    if (github != null) _profile.github = github;
    _changed();
  }

  void setExperience(int index, ExperienceEntry e) {
    if (index < 0 || index >= _profile.experience.length) return;
    _profile.experience[index] = e;
    _changed();
  }

  void addExperience() {
    _profile.experience.add(ExperienceEntry(bullets: ['']));
    _changed();
  }

  void removeExperienceAt(int index) {
    if (index < 0 || index >= _profile.experience.length) return;
    _profile.experience.removeAt(index);
    _changed();
  }

  void setEducation(int index, EducationEntry e) {
    if (index < 0 || index >= _profile.education.length) return;
    _profile.education[index] = e;
    _changed();
  }

  void addEducation() {
    _profile.education.add(EducationEntry());
    _changed();
  }

  void removeEducationAt(int index) {
    if (index < 0 || index >= _profile.education.length) return;
    _profile.education.removeAt(index);
    _changed();
  }

  void setTechnicalSkill(int index, String value) {
    if (index < 0 || index >= _profile.technicalSkills.length) return;
    _profile.technicalSkills[index] = value;
    _changed();
  }

  void addTechnicalSkill() {
    _profile.technicalSkills.add('');
    _changed();
  }

  void removeTechnicalSkillAt(int index) {
    if (index < 0 || index >= _profile.technicalSkills.length) return;
    _profile.technicalSkills.removeAt(index);
    _changed();
  }

  void setToolSkill(int index, String value) {
    if (index < 0 || index >= _profile.toolSkills.length) return;
    _profile.toolSkills[index] = value;
    _changed();
  }

  void addToolSkill() {
    _profile.toolSkills.add('');
    _changed();
  }

  void removeToolSkillAt(int index) {
    if (index < 0 || index >= _profile.toolSkills.length) return;
    _profile.toolSkills.removeAt(index);
    _changed();
  }

  void setSoftSkill(int index, String value) {
    if (index < 0 || index >= _profile.softSkills.length) return;
    _profile.softSkills[index] = value;
    _changed();
  }

  void addSoftSkill() {
    _profile.softSkills.add('');
    _changed();
  }

  void removeSoftSkillAt(int index) {
    if (index < 0 || index >= _profile.softSkills.length) return;
    _profile.softSkills.removeAt(index);
    _changed();
  }

  /// Legacy flat skills (optional); merged into technical in preview when ATS lists are empty.
  void setLegacySkill(int index, String value) {
    if (index < 0 || index >= _profile.skills.length) return;
    _profile.skills[index] = value;
    _changed();
  }

  void addLegacySkill() {
    _profile.skills.add('');
    _changed();
  }

  void removeLegacySkillAt(int index) {
    if (index < 0 || index >= _profile.skills.length) return;
    _profile.skills.removeAt(index);
    _changed();
  }

  void setLanguage(int index, LanguageEntry e) {
    if (index < 0 || index >= _profile.languages.length) return;
    _profile.languages[index] = e;
    _changed();
  }

  void addLanguage() {
    _profile.languages.add(LanguageEntry());
    _changed();
  }

  void removeLanguageAt(int index) {
    if (index < 0 || index >= _profile.languages.length) return;
    _profile.languages.removeAt(index);
    _changed();
  }

  void setProject(int index, ProjectEntry e) {
    if (index < 0 || index >= _profile.projects.length) return;
    _profile.projects[index] = e;
    _changed();
  }

  void addProject() {
    _profile.projects.add(ProjectEntry());
    _changed();
  }

  void removeProjectAt(int index) {
    if (index < 0 || index >= _profile.projects.length) return;
    _profile.projects.removeAt(index);
    _changed();
  }

  void setCertification(int index, CertificationEntry e) {
    if (index < 0 || index >= _profile.certifications.length) return;
    _profile.certifications[index] = e;
    _changed();
  }

  void addCertification() {
    _profile.certifications.add(CertificationEntry());
    _changed();
  }

  void removeCertificationAt(int index) {
    if (index < 0 || index >= _profile.certifications.length) return;
    _profile.certifications.removeAt(index);
    _changed();
  }

  void setAchievement(int index, String value) {
    if (index < 0 || index >= _profile.achievements.length) return;
    _profile.achievements[index] = value;
    _changed();
  }

  void addAchievement() {
    _profile.achievements.add('');
    _changed();
  }

  void removeAchievementAt(int index) {
    if (index < 0 || index >= _profile.achievements.length) return;
    _profile.achievements.removeAt(index);
    _changed();
  }

  void setInterests(String v) {
    _profile.interests = v;
    _changed();
  }

  void setVolunteer(String v) {
    _profile.volunteer = v;
    _changed();
  }

  void setPublications(String v) {
    _profile.publications = v;
    _changed();
  }

  void setSectionTitle(String sectionId, String title) {
    final i = _profile.sectionOrder.indexWhere((s) => s.id == sectionId);
    if (i < 0) return;
    _profile.sectionOrder[i].titleOverride = title;
    _changed();
  }

  void setCustomBody(String sectionId, String body) {
    final i = _profile.sectionOrder.indexWhere((s) => s.id == sectionId);
    if (i < 0) return;
    _profile.sectionOrder[i].customBody = body;
    _changed();
  }

  void removeSectionAt(int index) {
    if (index < 0 || index >= _profile.sectionOrder.length) return;
    _profile.sectionOrder.removeAt(index);
    _changed();
  }

  void reorderSections(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _profile.sectionOrder.removeAt(oldIndex);
    _profile.sectionOrder.insert(newIndex, item);
    _changed();
  }

  void addSection(ResumeSectionKind kind, {String title = ''}) {
    _profile.sectionOrder.add(
      ResumeSectionSlot(
        id: '${kind.name}_${DateTime.now().microsecondsSinceEpoch}',
        kind: kind,
        titleOverride: title.trim(),
      ),
    );
    _changed();
  }

  void addCustomSection({String title = ''}) {
    _profile.sectionOrder.add(
      ResumeSectionSlot(
        id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
        kind: ResumeSectionKind.custom,
        titleOverride: title.trim(),
        customBody: '',
      ),
    );
    _changed();
  }

  void clearAll() {
    _profile = CvProfile(sectionOrder: defaultSectionOrder());
    _changed();
  }
}
