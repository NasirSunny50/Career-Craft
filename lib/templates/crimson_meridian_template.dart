import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cv_profile.dart';
import 'cv_content_helpers.dart';
import 'cv_slot_builder.dart';

class CrimsonMeridianTemplate extends StatelessWidget {
  const CrimsonMeridianTemplate({super.key, required this.profile});

  final CvProfile profile;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.sourceSans3(
      fontSize: 11.5,
      height: 1.55,
      color: const Color(0xFF334155),
    );
    final metaStyle = GoogleFonts.sourceSans3(fontSize: 10.5, color: const Color(0xFF64748B));
    final boldStyle = GoogleFonts.sourceSans3(
      fontSize: 12.5,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF0F172A),
    );
    final bulletStyle = GoogleFonts.sourceSans3(fontSize: 11, color: const Color(0xFFE11D48));
    final subLabelStyle = GoogleFonts.sourceSans3(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF9F1239),
    );

    final slotTheme = CvSlotTextTheme(
      body: bodyStyle,
      meta: metaStyle,
      bold: boldStyle,
      bullet: bulletStyle,
      subLabel: subLabelStyle,
      link: GoogleFonts.sourceSans3(fontSize: 10.5, color: const Color(0xFF9F1239)),
    );

    final contact = displayContactLine(profile);
    final social = displaySocialLine(profile);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            decoration: const BoxDecoration(
              color: Color(0xFF9F1239),
              boxShadow: [
                BoxShadow(
                  color: Color(0x339F1239),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.title,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                if (contact.isNotEmpty)
                  Text(
                    contact,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                if (social.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    social,
                    style: GoogleFonts.sourceSans3(
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
                      _stripeSection(
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

  Widget _stripeSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.sourceSans3(
                fontSize: 11,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF9F1239),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
