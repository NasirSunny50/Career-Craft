import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cv_profile.dart';
import 'cv_content_helpers.dart';
import 'cv_slot_builder.dart';

class ObsidianForgeTemplate extends StatelessWidget {
  const ObsidianForgeTemplate({super.key, required this.profile});

  final CvProfile profile;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.inter(
      fontSize: 10.8,
      height: 1.55,
      color: const Color(0xFF334155),
    );
    final metaStyle = GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B));
    final boldStyle = GoogleFonts.spaceGrotesk(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF0F172A),
    );
    final bulletStyle = GoogleFonts.spaceGrotesk(fontSize: 11, color: const Color(0xFF22D3EE));
    final subLabelStyle = GoogleFonts.spaceGrotesk(
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF22D3EE),
    );

    final slotTheme = CvSlotTextTheme(
      body: bodyStyle,
      meta: metaStyle,
      bold: boldStyle,
      bullet: bulletStyle,
      subLabel: subLabelStyle,
      link: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF0EA5E9)),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 42,
          child: Container(
            color: const Color(0xFF0B1220),
            padding: const EdgeInsets.fromLTRB(16, 24, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 3,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),
                _sideHeading('Contact'),
                if (profile.email.trim().isNotEmpty)
                  _sideLine(Icons.mail_outline_rounded, profile.email),
                if (profile.phone.trim().isNotEmpty)
                  _sideLine(Icons.phone_iphone_rounded, profile.phone),
                if (profile.location.trim().isNotEmpty)
                  _sideLine(Icons.location_on_outlined, profile.location),
                if (profile.linkedin.trim().isNotEmpty)
                  _sideLine(Icons.link, profile.linkedin),
                if (profile.portfolio.trim().isNotEmpty)
                  _sideLine(Icons.language_rounded, profile.portfolio),
                if (profile.github.trim().isNotEmpty)
                  _sideLine(Icons.code_rounded, profile.github),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 58,
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final slot in profile.sectionOrder)
                    if (slotShouldRender(profile, slot)) ...[
                      Text(
                        effectiveSectionTitle(slot).toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildSlotBody(profile, slot, slotTheme),
                      const SizedBox(height: 20),
                    ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sideHeading(String t) {
    return Text(
      t.toUpperCase(),
      style: GoogleFonts.spaceGrotesk(
        fontSize: 9.5,
        letterSpacing: 1.8,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF22D3EE),
      ),
    );
  }

  Widget _sideLine(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.trim(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                height: 1.35,
                color: const Color(0xFFE2E8F0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
