import 'package:flutter/material.dart';

import '../models/cv_profile.dart';
import 'cv_content_helpers.dart';

/// Shared text styles for section bodies across templates.
class CvSlotTextTheme {
  const CvSlotTextTheme({
    required this.body,
    required this.meta,
    required this.bold,
    required this.bullet,
    this.subLabel,
    this.link,
  });

  final TextStyle body;
  final TextStyle meta;
  final TextStyle bold;
  final TextStyle bullet;
  final TextStyle? subLabel;
  final TextStyle? link;
}

Widget buildSlotBody(CvProfile p, ResumeSectionSlot slot, CvSlotTextTheme t) {
  switch (slot.kind) {
    case ResumeSectionKind.summary:
      return Text(p.summary, style: t.body);
    case ResumeSectionKind.experience:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in p.experience)
            if (experienceEntryHasContent(e)) ...[
              _jobHeader(e, t),
              if (nonEmptyBullets(e).isNotEmpty) ...[
                const SizedBox(height: 6),
                for (final b in nonEmptyBullets(e))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: t.bullet),
                        Expanded(child: Text(b, style: t.body)),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 12),
            ],
        ],
      );
    case ResumeSectionKind.education:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final ed in p.education)
            if (educationEntryHasContent(ed))
              _educationBlock(ed, t),
        ],
      );
    case ResumeSectionKind.skills:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mergedTechnical(p).isNotEmpty) ...[
            if (t.subLabel != null) Text('Technical', style: t.subLabel),
            const SizedBox(height: 4),
            Text(mergedTechnical(p).join(', '), style: t.body),
            const SizedBox(height: 10),
          ],
          if (mergedTools(p).isNotEmpty) ...[
            if (t.subLabel != null) Text('Tools', style: t.subLabel),
            const SizedBox(height: 4),
            Text(mergedTools(p).join(', '), style: t.body),
            const SizedBox(height: 10),
          ],
          if (mergedSoft(p).isNotEmpty) ...[
            if (t.subLabel != null) Text('Soft skills', style: t.subLabel),
            const SizedBox(height: 4),
            Text(mergedSoft(p).join(', '), style: t.body),
          ],
        ],
      );
    case ResumeSectionKind.projects:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final pr in p.projects)
            if (projectEntryHasContent(pr)) ...[
              Text(pr.name.trim().isNotEmpty ? pr.name : 'Project', style: t.bold),
              if (pr.techStack.trim().isNotEmpty)
                Text(pr.techStack, style: t.meta),
              if (pr.description.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(pr.description, style: t.body),
                ),
              if (pr.link.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(pr.link, style: t.link ?? t.meta),
                ),
              const SizedBox(height: 10),
            ],
        ],
      );
    case ResumeSectionKind.certifications:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in p.certifications)
            if (certEntryHasContent(c)) ...[
              Text(c.name.trim().isNotEmpty ? c.name : 'Certification', style: t.bold),
              Text(
                [
                  if (c.issuer.trim().isNotEmpty) c.issuer,
                  if (c.year.trim().isNotEmpty) c.year,
                ].join(' · '),
                style: t.meta,
              ),
              if (c.detail.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(c.detail, style: t.body),
                ),
              const SizedBox(height: 8),
            ],
        ],
      );
    case ResumeSectionKind.achievements:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final a in p.achievements)
            if (a.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: t.bullet),
                    Expanded(child: Text(a, style: t.body)),
                  ],
                ),
              ),
        ],
      );
    case ResumeSectionKind.languages:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in p.languages)
            if (l.name.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  l.level.isEmpty ? l.name.trim() : '${l.name.trim()} — ${l.level}',
                  style: t.body,
                ),
              ),
        ],
      );
    case ResumeSectionKind.interests:
      return Text(p.interests, style: t.body);
    case ResumeSectionKind.volunteer:
      return Text(p.volunteer, style: t.body);
    case ResumeSectionKind.publications:
      return Text(p.publications, style: t.body);
    case ResumeSectionKind.custom:
      return Text(slot.customBody, style: t.body);
  }
}

Widget _educationBlock(EducationEntry ed, CvSlotTextTheme t) {
  final deg = ed.degree.trim();
  final inst = ed.institution.trim();
  final per = ed.period.trim();
  final children = <Widget>[];

  if (deg.isNotEmpty) {
    children.add(Text(deg, style: t.bold));
    final line2 = [inst, per].where((s) => s.isNotEmpty).join(' · ');
    if (line2.isNotEmpty) {
      children.add(Text(line2, style: t.meta));
    }
  } else if (inst.isNotEmpty) {
    children.add(Text(inst, style: t.bold));
    if (per.isNotEmpty) {
      children.add(Text(per, style: t.meta));
    }
  } else if (per.isNotEmpty) {
    children.add(Text(per, style: t.bold));
  }

  if (ed.cgpa.trim().isNotEmpty) {
    children.add(Text('CGPA: ${ed.cgpa.trim()}', style: t.meta));
  }
  if (ed.detail.trim().isNotEmpty) {
    children.add(
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(ed.detail, style: t.body),
      ),
    );
  }
  children.add(const SizedBox(height: 10));

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}

Widget _jobHeader(ExperienceEntry e, CvSlotTextTheme t) {
  final role = e.role.trim();
  final company = e.company.trim();
  final period = e.period.trim();

  if (role.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(role, style: t.bold)),
            if (period.isNotEmpty) Text(period, style: t.meta),
          ],
        ),
        if (company.isNotEmpty) Text(company, style: t.meta),
      ],
    );
  }
  if (company.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(company, style: t.bold)),
            if (period.isNotEmpty) Text(period, style: t.meta),
          ],
        ),
      ],
    );
  }
  if (period.isNotEmpty) {
    return Text(period, style: t.meta);
  }
  return const SizedBox.shrink();
}
