import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cv_profile.dart';
import 'cv_content_helpers.dart';
import 'cv_slot_builder.dart';

class AuroraAscentTemplate extends StatelessWidget {
  const AuroraAscentTemplate({super.key, required this.profile});

  final CvProfile profile;

  @override
  Widget build(BuildContext context) {
    final nameStyle = GoogleFonts.dmSans(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      height: 1.05,
    );
    final titleStyle = GoogleFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.92),
    );

    final bodyStyle = GoogleFonts.dmSans(
      fontSize: 11.5,
      height: 1.55,
      color: const Color(0xFF334155),
    );
    final metaStyle = GoogleFonts.dmSans(fontSize: 10.5, color: const Color(0xFF64748B));
    final boldStyle = GoogleFonts.dmSans(
      fontSize: 12.5,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF0F172A),
    );
    final bulletStyle = GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF6366F1));
    final subLabelStyle = GoogleFonts.dmSans(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF4338CA),
    );

    final slotTheme = CvSlotTextTheme(
      body: bodyStyle,
      meta: metaStyle,
      bold: boldStyle,
      bullet: bulletStyle,
      subLabel: subLabelStyle,
      link: GoogleFonts.dmSans(fontSize: 10.5, color: const Color(0xFF4338CA)),
    );

    final contact = displayContactLine(profile);
    final social = displaySocialLine(profile);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4338CA),
                  Color(0xFF6366F1),
                  Color(0xFFA5B4FC),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: nameStyle,
                ),
                const SizedBox(height: 6),
                Text(
                  profile.title,
                  style: titleStyle,
                ),
                const SizedBox(height: 14),
                if (contact.isNotEmpty)
                  Text(
                    contact,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                if (social.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    social,
                    style: GoogleFonts.dmSans(
                      fontSize: 10.5,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final slot in profile.sectionOrder)
                    if (slotShouldRender(profile, slot)) ...[
                      _accentSection(
                        title: effectiveSectionTitle(slot),
                        child: buildSlotBody(profile, slot, slotTheme),
                      ),
                      const SizedBox(height: 18),
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accentSection({required String title, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          constraints: const BoxConstraints(minHeight: 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6366F1), Color(0xFFA5B4FC)],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4338CA),
                ),
              ),
              child,
            ],
          ),
        ),
      ],
    );
  }
}
