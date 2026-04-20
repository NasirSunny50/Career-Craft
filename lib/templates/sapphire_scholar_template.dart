import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cv_profile.dart';
import 'cv_content_helpers.dart';
import 'cv_slot_builder.dart';

class SapphireScholarTemplate extends StatelessWidget {
  const SapphireScholarTemplate({super.key, required this.profile});

  final CvProfile profile;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.lato(
      fontSize: 11.3,
      height: 1.55,
      color: const Color(0xFF334155),
    );
    final metaStyle = GoogleFonts.lato(fontSize: 10.5, color: const Color(0xFF64748B));
    final boldStyle = GoogleFonts.lato(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF0F172A),
    );
    final bulletStyle = GoogleFonts.lato(fontSize: 11, color: const Color(0xFF2563EB));
    final subLabelStyle = GoogleFonts.lato(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF1E3A8A),
    );

    final slotTheme = CvSlotTextTheme(
      body: bodyStyle,
      meta: metaStyle,
      bold: boldStyle,
      bullet: bulletStyle,
      subLabel: subLabelStyle,
      link: GoogleFonts.lato(fontSize: 10.5, color: const Color(0xFF2563EB)),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 36,
          child: Container(
            color: const Color(0xFF1E40AF),
            padding: const EdgeInsets.fromLTRB(14, 22, 14, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: GoogleFonts.ebGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.title,
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                _label('Contact'),
                if (profile.email.trim().isNotEmpty) _line(profile.email),
                if (profile.phone.trim().isNotEmpty) _line(profile.phone),
                if (profile.location.trim().isNotEmpty) _line(profile.location),
                if (profile.linkedin.trim().isNotEmpty) _line(profile.linkedin),
                if (profile.portfolio.trim().isNotEmpty) _line(profile.portfolio),
                if (profile.github.trim().isNotEmpty) _line(profile.github),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    'References available upon request.',
                    style: GoogleFonts.lato(
                      fontSize: 9.5,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 64,
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final slot in profile.sectionOrder)
                    if (slotShouldRender(profile, slot)) ...[
                      _paperTitle(effectiveSectionTitle(slot)),
                      const SizedBox(height: 8),
                      buildSlotBody(profile, slot, slotTheme),
                      const SizedBox(height: 18),
                    ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        t.toUpperCase(),
        style: GoogleFonts.lato(
          fontSize: 9,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFBFDBFE),
        ),
      ),
    );
  }

  Widget _line(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        value.trim(),
        style: GoogleFonts.lato(
          fontSize: 10.5,
          color: Colors.white,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _paperTitle(String t) {
    return Text(
      t.toUpperCase(),
      style: GoogleFonts.ebGaramond(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: const Color(0xFF1E3A8A),
      ),
    );
  }
}
