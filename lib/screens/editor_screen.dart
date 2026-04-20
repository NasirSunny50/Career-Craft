import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/cv_profile.dart';
import '../providers/cv_provider.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit CV'),
      ),
      body: Consumer<CvController>(
        builder: (context, c, _) {
          final p = c.profile;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                'Personal Information',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              _Field(
                label: 'Full Name',
                hint: 'As it should appear on the CV',
                initial: p.fullName,
                onChanged: (v) => c.updateBasics(fullName: v),
              ),
              _Field(
                label: 'Target Role / Headline',
                hint: 'e.g. Product Designer',
                initial: p.title,
                onChanged: (v) => c.updateBasics(title: v),
              ),
              _Field(
                label: 'Email',
                hint: 'name@example.com',
                initial: p.email,
                keyboard: TextInputType.emailAddress,
                onChanged: (v) => c.updateBasics(email: v),
              ),
              _Field(
                label: 'Phone',
                hint: 'Include country code if applying abroad',
                initial: p.phone,
                keyboard: TextInputType.phone,
                onChanged: (v) => c.updateBasics(phone: v),
              ),
              _Field(
                label: 'Location',
                hint: 'City, country',
                initial: p.location,
                onChanged: (v) => c.updateBasics(location: v),
              ),
              _Field(
                label: 'LinkedIn',
                initial: p.linkedin,
                onChanged: (v) => c.updateBasics(linkedin: v),
              ),
              _Field(
                label: 'Portfolio / Website',
                initial: p.portfolio,
                onChanged: (v) => c.updateBasics(portfolio: v),
              ),
              _Field(
                label: 'GitHub',
                initial: p.github,
                onChanged: (v) => c.updateBasics(github: v),
              ),
              const SizedBox(height: 16),
              _SectionManager(),
              const SizedBox(height: 8),
              ...p.sectionOrder.asMap().entries.map((e) {
                return _SectionFormBlock(
                  key: ValueKey(e.value.id),
                  index: e.key,
                  slot: e.value,
                );
              }),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear all fields?'),
                      content: const Text(
                        'This removes everything and restores the default list of sections. This cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            c.clearAll();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Clear all'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<CvController>();
    final order = c.profile.sectionOrder;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sections',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _pickAddSection(context, c),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Drag to reorder or remove. Tap the pencil next to a section name to rename it. Removing a section keeps your text.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.length,
              onReorder: c.reorderSections,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, anim) => Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: child,
              ),
              itemBuilder: (context, index) {
                final slot = order[index];
                final defaultTitle = kDefaultSectionTitles[slot.kind] ??
                    (slot.kind == ResumeSectionKind.custom ? 'Custom' : 'Section');
                return Card(
                  key: ValueKey(slot.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle_rounded),
                    ),
                    title: Text(
                      slot.titleOverride.trim().isNotEmpty
                          ? slot.titleOverride.trim()
                          : defaultTitle,
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    subtitle: Text(
                      slot.kind == ResumeSectionKind.custom
                          ? 'Custom block'
                          : defaultTitle,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11),
                    ),
                    trailing: IconButton(
                      tooltip: 'Remove section',
                      onPressed: () => c.removeSectionAt(index),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Optional title when adding; empty keeps the default heading for that section type.
  static Future<void> _promptNewSectionTitle(
    BuildContext context,
    CvController c,
    ResumeSectionKind kind,
  ) async {
    final defaultTitle = kDefaultSectionTitles[kind] ??
        (kind == ResumeSectionKind.custom ? 'Custom section' : kind.name);
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            'Section Title',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Shows on your CV',
              hintText: defaultTitle,
            ),
            onSubmitted: (_) {
              final t = ctrl.text.trim();
              Navigator.pop(dialogCtx);
              _applyNewSection(c, kind, t);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                _applyNewSection(c, kind, '');
              },
              child: const Text('Use Default'),
            ),
            FilledButton(
              onPressed: () {
                final t = ctrl.text.trim();
                Navigator.pop(dialogCtx);
                _applyNewSection(c, kind, t);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    ctrl.dispose();
  }

  static void _applyNewSection(CvController c, ResumeSectionKind kind, String title) {
    if (kind == ResumeSectionKind.custom) {
      c.addCustomSection(title: title);
    } else {
      c.addSection(kind, title: title);
    }
  }

  static Future<void> _pickAddSection(BuildContext context, CvController c) async {
    final used = c.profile.sectionOrder.map((s) => s.kind).toSet();
    final choices = ResumeSectionKind.values.where((k) {
      if (k == ResumeSectionKind.custom) return true;
      return !used.contains(k);
    }).toList();

    if (choices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All section types are already added. Add another custom block, or remove one first.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Add Section',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              for (final k in choices)
                ListTile(
                  title: Text(
                    k == ResumeSectionKind.custom
                        ? 'Custom (free text)'
                        : (kDefaultSectionTitles[k] ?? k.name),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _promptNewSectionTitle(context, c, k);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionFormBlock extends StatelessWidget {
  const _SectionFormBlock({
    super.key,
    required this.index,
    required this.slot,
  });

  final int index;
  final ResumeSectionSlot slot;

  static Future<void> _showRenameSectionDialog(
    BuildContext context,
    CvController c,
    ResumeSectionSlot slot,
  ) async {
    final defaultTitle = kDefaultSectionTitles[slot.kind] ??
        (slot.kind == ResumeSectionKind.custom ? 'Custom' : 'Section');
    final ctrl = TextEditingController(text: slot.titleOverride);
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            'Rename Section',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Heading on your CV',
              hintText: defaultTitle,
            ),
            onSubmitted: (_) {
              c.setSectionTitle(slot.id, ctrl.text.trim());
              Navigator.pop(dialogCtx);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                c.setSectionTitle(slot.id, '');
                Navigator.pop(dialogCtx);
              },
              child: const Text('Use Default'),
            ),
            FilledButton(
              onPressed: () {
                c.setSectionTitle(slot.id, ctrl.text.trim());
                Navigator.pop(dialogCtx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.read<CvController>();
    final defaultTitle = kDefaultSectionTitles[slot.kind] ??
        (slot.kind == ResumeSectionKind.custom ? 'Custom' : 'Section');
    final heading = slot.titleOverride.trim().isNotEmpty
        ? slot.titleOverride.trim()
        : defaultTitle;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    heading,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Rename section heading',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                  ),
                  onPressed: () => _showRenameSectionDialog(context, c, slot),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionBody(slot: slot),
          ],
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.slot});

  final ResumeSectionSlot slot;

  @override
  Widget build(BuildContext context) {
    final c = context.read<CvController>();
    switch (slot.kind) {
      case ResumeSectionKind.summary:
        return _Field(
          hint: '2–4 lines: who you are, role, key strengths',
          initial: c.profile.summary,
          maxLines: 6,
          onChanged: (v) => c.updateBasics(summary: v),
        );
      case ResumeSectionKind.experience:
        return _ExperienceBlock();
      case ResumeSectionKind.education:
        return _EducationBlock();
      case ResumeSectionKind.skills:
        return _SkillsBlock();
      case ResumeSectionKind.projects:
        return _ProjectsBlock();
      case ResumeSectionKind.certifications:
        return _CertificationsBlock();
      case ResumeSectionKind.achievements:
        return _AchievementsBlock();
      case ResumeSectionKind.languages:
        return _LanguagesBlock();
      case ResumeSectionKind.interests:
        return _Field(
          hint: 'Short list or one line',
          initial: c.profile.interests,
          maxLines: 4,
          onChanged: c.setInterests,
        );
      case ResumeSectionKind.volunteer:
        return _Field(
          hint: 'Role, organization, dates, impact',
          initial: c.profile.volunteer,
          maxLines: 8,
          onChanged: c.setVolunteer,
        );
      case ResumeSectionKind.publications:
        return _Field(
          hint: 'One entry per line',
          initial: c.profile.publications,
          maxLines: 8,
          onChanged: c.setPublications,
        );
      case ResumeSectionKind.custom:
        return Consumer<CvController>(
          builder: (context, ctrl, _) {
            final matches = ctrl.profile.sectionOrder.where((s) => s.id == slot.id);
            final live = matches.isNotEmpty ? matches.first : slot;
            return _Field(
              hint: 'Anything you want under this heading',
              initial: live.customBody,
              maxLines: 12,
              onChanged: (v) => c.setCustomBody(slot.id, v),
            );
          },
        );
    }
  }
}

class _ExperienceBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<CvController>();
    final p = c.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...p.experience.asMap().entries.map((e) {
          final i = e.key;
          final x = e.value;
          return _ExperienceCard(
            key: ValueKey(x.id),
            index: i,
            entry: x,
            onChanged: (next) => c.setExperience(i, next),
            onRemove: () => c.removeExperienceAt(i),
          );
        }),
        TextButton.icon(
          onPressed: c.addExperience,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Role'),
        ),
      ],
    );
  }
}

class _EducationBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<CvController>();
    final p = c.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...p.education.asMap().entries.map((e) {
          final i = e.key;
          final x = e.value;
          return _EducationCard(
            key: ValueKey(x.id),
            index: i,
            entry: x,
            onChanged: (next) => c.setEducation(i, next),
            onRemove: () => c.removeEducationAt(i),
          );
        }),
        TextButton.icon(
          onPressed: c.addEducation,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Education'),
        ),
      ],
    );
  }
}

class _SkillsBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<CvController>();
    final p = c.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical Skills',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 6),
        ...p.technicalSkills.asMap().entries.map((e) {
          final i = e.key;
          return _skillRow(
            context,
            e.value,
            (v) => c.setTechnicalSkill(i, v),
            () => c.removeTechnicalSkillAt(i),
          );
        }),
        TextButton.icon(
          onPressed: c.addTechnicalSkill,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Technical Skill'),
        ),
        const SizedBox(height: 12),
        Text(
          'Tools',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 6),
        ...p.toolSkills.asMap().entries.map((e) {
          final i = e.key;
          return _skillRow(
            context,
            e.value,
            (v) => c.setToolSkill(i, v),
            () => c.removeToolSkillAt(i),
          );
        }),
        TextButton.icon(
          onPressed: c.addToolSkill,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add tool'),
        ),
        const SizedBox(height: 12),
        Text(
          'Soft Skills',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 6),
        ...p.softSkills.asMap().entries.map((e) {
          final i = e.key;
          return _skillRow(
            context,
            e.value,
            (v) => c.setSoftSkill(i, v),
            () => c.removeSoftSkillAt(i),
          );
        }),
        TextButton.icon(
          onPressed: c.addSoftSkill,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Soft Skill'),
        ),
      ],
    );
  }

  Widget _skillRow(
    BuildContext context,
    String initial,
    ValueChanged<String> onChanged,
    VoidCallback onRemove,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: _Field(
              label: 'Skill',
              initial: initial,
              onChanged: onChanged,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _ProjectsBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<CvController>();
    final p = c.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...p.projects.asMap().entries.map((e) {
          final i = e.key;
          final x = e.value;
          return _ProjectCard(
            key: ValueKey(x.id),
            entry: x,
            onChanged: (next) => c.setProject(i, next),
            onRemove: () => c.removeProjectAt(i),
          );
        }),
        TextButton.icon(
          onPressed: c.addProject,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Project'),
        ),
      ],
    );
  }
}

class _CertificationsBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<CvController>();
    final p = c.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...p.certifications.asMap().entries.map((e) {
          final i = e.key;
          final x = e.value;
          return _CertCard(
            key: ValueKey(x.id),
            entry: x,
            onChanged: (next) => c.setCertification(i, next),
            onRemove: () => c.removeCertificationAt(i),
          );
        }),
        TextButton.icon(
          onPressed: c.addCertification,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Certification'),
        ),
      ],
    );
  }
}

class _AchievementsBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<CvController>();
    final p = c.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...p.achievements.asMap().entries.map((e) {
          final i = e.key;
          final a = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Field(
                    label: 'Achievement',
                    initial: a,
                    maxLines: 3,
                    onChanged: (v) => c.setAchievement(i, v),
                  ),
                ),
                IconButton(
                  onPressed: () => c.removeAchievementAt(i),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: c.addAchievement,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Achievement'),
        ),
      ],
    );
  }
}

class _LanguagesBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<CvController>();
    final p = c.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...p.languages.asMap().entries.map((e) {
          final i = e.key;
          final x = e.value;
          return _LanguageCard(
            key: ValueKey(x.id),
            index: i,
            entry: x,
            onChanged: (next) => c.setLanguage(i, next),
            onRemove: p.languages.length > 1 ? () => c.removeLanguageAt(i) : null,
          );
        }),
        TextButton.icon(
          onPressed: c.addLanguage,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Language'),
        ),
      ],
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    this.label,
    required this.initial,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboard,
    this.hint,
  });

  /// When null, only [hint] is shown (no floating label)—use when the section heading already names the field.
  final String? label;
  final String initial;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextInputType? keyboard;
  final String? hint;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initial);
  }

  @override
  void didUpdateWidget(covariant _Field oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial && widget.initial != _c.text) {
      _c.text = widget.initial;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _c,
        onChanged: widget.onChanged,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboard,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          alignLabelWithHint: widget.label == null,
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatefulWidget {
  const _ExperienceCard({
    super.key,
    required this.index,
    required this.entry,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final ExperienceEntry entry;
  final ValueChanged<ExperienceEntry> onChanged;
  final VoidCallback onRemove;

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  late TextEditingController _role;
  late TextEditingController _company;
  late TextEditingController _period;
  late List<TextEditingController> _bullets;

  @override
  void initState() {
    super.initState();
    _role = TextEditingController(text: widget.entry.role);
    _company = TextEditingController(text: widget.entry.company);
    _period = TextEditingController(text: widget.entry.period);
    _bullets = widget.entry.bullets
        .map((s) => TextEditingController(text: s))
        .toList();
    if (_bullets.isEmpty) {
      _bullets = [TextEditingController()];
    }
    for (final b in _bullets) {
      b.addListener(_syncBullets);
    }
    _role.addListener(_emitBasics);
    _company.addListener(_emitBasics);
    _period.addListener(_emitBasics);
  }

  @override
  void didUpdateWidget(covariant _ExperienceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _detachBulletListeners();
      _role.text = widget.entry.role;
      _company.text = widget.entry.company;
      _period.text = widget.entry.period;
      for (final b in _bullets) {
        b.dispose();
      }
      _bullets = widget.entry.bullets
          .map((s) => TextEditingController(text: s))
          .toList();
      if (_bullets.isEmpty) {
        _bullets = [TextEditingController()];
      }
      for (final b in _bullets) {
        b.addListener(_syncBullets);
      }
    }
  }

  void _detachBulletListeners() {
    for (final b in _bullets) {
      b.removeListener(_syncBullets);
    }
  }

  @override
  void dispose() {
    _role.removeListener(_emitBasics);
    _company.removeListener(_emitBasics);
    _period.removeListener(_emitBasics);
    _role.dispose();
    _company.dispose();
    _period.dispose();
    _detachBulletListeners();
    for (final b in _bullets) {
      b.dispose();
    }
    super.dispose();
  }

  void _emitBasics() {
    widget.onChanged(
      widget.entry.copyWith(
        role: _role.text,
        company: _company.text,
        period: _period.text,
        bullets: _bullets.map((c) => c.text).toList(),
      ),
    );
  }

  void _syncBullets() {
    widget.onChanged(
      widget.entry.copyWith(
        role: _role.text,
        company: _company.text,
        period: _period.text,
        bullets: _bullets.map((c) => c.text).toList(),
      ),
    );
  }

  void _addBullet() {
    setState(() {
      final n = TextEditingController();
      n.addListener(_syncBullets);
      _bullets.add(n);
    });
    _syncBullets();
  }

  void _removeBullet(int i) {
    setState(() {
      final b = _bullets.removeAt(i);
      b.removeListener(_syncBullets);
      b.dispose();
    });
    _syncBullets();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Role ${widget.index + 1}',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Job title'),
              controller: _role,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Company'),
              controller: _company,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Duration'),
              controller: _period,
            ),
            const SizedBox(height: 8),
            Text(
              'Responsibilities & achievements',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ..._bullets.asMap().entries.map((be) {
              final bi = be.key;
              final ctrl = be.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Point ${bi + 1}',
                        ),
                        controller: ctrl,
                        maxLines: 3,
                      ),
                    ),
                    if (_bullets.length > 1)
                      IconButton(
                        onPressed: () => _removeBullet(bi),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addBullet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Bullet'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationCard extends StatefulWidget {
  const _EducationCard({
    super.key,
    required this.index,
    required this.entry,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final EducationEntry entry;
  final ValueChanged<EducationEntry> onChanged;
  final VoidCallback onRemove;

  @override
  State<_EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<_EducationCard> {
  late TextEditingController _degree;
  late TextEditingController _inst;
  late TextEditingController _period;
  late TextEditingController _cgpa;
  late TextEditingController _detail;

  @override
  void initState() {
    super.initState();
    _degree = TextEditingController(text: widget.entry.degree);
    _inst = TextEditingController(text: widget.entry.institution);
    _period = TextEditingController(text: widget.entry.period);
    _cgpa = TextEditingController(text: widget.entry.cgpa);
    _detail = TextEditingController(text: widget.entry.detail);
    _degree.addListener(_emit);
    _inst.addListener(_emit);
    _period.addListener(_emit);
    _cgpa.addListener(_emit);
    _detail.addListener(_emit);
  }

  @override
  void didUpdateWidget(covariant _EducationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _degree.text = widget.entry.degree;
      _inst.text = widget.entry.institution;
      _period.text = widget.entry.period;
      _cgpa.text = widget.entry.cgpa;
      _detail.text = widget.entry.detail;
    }
  }

  @override
  void dispose() {
    _degree.dispose();
    _inst.dispose();
    _period.dispose();
    _cgpa.dispose();
    _detail.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      EducationEntry(
        id: widget.entry.id,
        degree: _degree.text,
        institution: _inst.text,
        period: _period.text,
        cgpa: _cgpa.text,
        detail: _detail.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Education ${widget.index + 1}',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Degree'),
              controller: _degree,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Institution'),
              controller: _inst,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Year / period'),
              controller: _period,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'CGPA (optional)'),
              controller: _cgpa,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Details (optional)'),
              controller: _detail,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatefulWidget {
  const _LanguageCard({
    super.key,
    required this.index,
    required this.entry,
    required this.onChanged,
    this.onRemove,
  });

  final int index;
  final LanguageEntry entry;
  final ValueChanged<LanguageEntry> onChanged;
  final VoidCallback? onRemove;

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard> {
  late TextEditingController _name;
  late TextEditingController _level;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.entry.name);
    _level = TextEditingController(text: widget.entry.level);
    _name.addListener(_emit);
    _level.addListener(_emit);
  }

  @override
  void didUpdateWidget(covariant _LanguageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _name.text = widget.entry.name;
      _level.text = widget.entry.level;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _level.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      LanguageEntry(
        id: widget.entry.id,
        name: _name.text,
        level: _level.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Language ${widget.index + 1}',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Language'),
              controller: _name,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Level (e.g. Fluent, Native)'),
              controller: _level,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({
    super.key,
    required this.entry,
    required this.onChanged,
    required this.onRemove,
  });

  final ProjectEntry entry;
  final ValueChanged<ProjectEntry> onChanged;
  final VoidCallback onRemove;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  late TextEditingController _name;
  late TextEditingController _stack;
  late TextEditingController _desc;
  late TextEditingController _link;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.entry.name);
    _stack = TextEditingController(text: widget.entry.techStack);
    _desc = TextEditingController(text: widget.entry.description);
    _link = TextEditingController(text: widget.entry.link);
    for (final c in [_name, _stack, _desc, _link]) {
      c.addListener(_emit);
    }
  }

  @override
  void didUpdateWidget(covariant _ProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _name.text = widget.entry.name;
      _stack.text = widget.entry.techStack;
      _desc.text = widget.entry.description;
      _link.text = widget.entry.link;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _stack, _desc, _link]) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      ProjectEntry(
        id: widget.entry.id,
        name: _name.text,
        techStack: _stack.text,
        description: _desc.text,
        link: _link.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Project',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Project name'),
              controller: _name,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Tech stack'),
              controller: _stack,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              controller: _desc,
              maxLines: 4,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Live link / GitHub'),
              controller: _link,
            ),
          ],
        ),
      ),
    );
  }
}

class _CertCard extends StatefulWidget {
  const _CertCard({
    super.key,
    required this.entry,
    required this.onChanged,
    required this.onRemove,
  });

  final CertificationEntry entry;
  final ValueChanged<CertificationEntry> onChanged;
  final VoidCallback onRemove;

  @override
  State<_CertCard> createState() => _CertCardState();
}

class _CertCardState extends State<_CertCard> {
  late TextEditingController _name;
  late TextEditingController _issuer;
  late TextEditingController _year;
  late TextEditingController _detail;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.entry.name);
    _issuer = TextEditingController(text: widget.entry.issuer);
    _year = TextEditingController(text: widget.entry.year);
    _detail = TextEditingController(text: widget.entry.detail);
    for (final c in [_name, _issuer, _year, _detail]) {
      c.addListener(_emit);
    }
  }

  @override
  void didUpdateWidget(covariant _CertCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _name.text = widget.entry.name;
      _issuer.text = widget.entry.issuer;
      _year.text = widget.entry.year;
      _detail.text = widget.entry.detail;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _issuer, _year, _detail]) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      CertificationEntry(
        id: widget.entry.id,
        name: _name.text,
        issuer: _issuer.text,
        year: _year.text,
        detail: _detail.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Certification',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              controller: _name,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Issuer'),
              controller: _issuer,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Year'),
              controller: _year,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Details (optional)'),
              controller: _detail,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
