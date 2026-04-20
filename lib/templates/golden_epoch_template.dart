import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cv_profile.dart';
import 'cv_content_helpers.dart';
import 'cv_slot_builder.dart';

class GoldenEpochTemplate extends StatelessWidget {
  const GoldenEpochTemplate({super.key, required this.profile});

  final CvProfile profile;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.cormorantGaramond(
      fontSize: 12.5,
      height: 1.55,
      color: const Color(0xFF44403C),
    );
    final metaStyle = GoogleFonts.cormorantGaramond(
      fontSize: 11.5,
      color: const Color(0xFF78716C),
    );
    final boldStyle = GoogleFonts.playfairDisplay(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF292524),
    );
    final bulletStyle = GoogleFonts.cormorantGaramond(
      fontSize: 12,
      color: const Color(0xFFB45309),
    );
    final subLabelStyle = GoogleFonts.playfairDisplay(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF78350F),
    );

    final slotTheme = CvSlotTextTheme(
      body: bodyStyle,
      meta: metaStyle,
      bold: boldStyle,
      bullet: bulletStyle,
      subLabel: subLabelStyle,
      link: GoogleFonts.cormorantGaramond(
        fontSize: 11.5,
        color: const Color(0xFF92400E),
      ),
    );

    final contact = displayContactLine(profile);
    final social = displaySocialLine(profile);

    return Container(
      color: const Color(0xFFFFFBF0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              profile.fullName,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF422006),
                height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              width: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x33B45309), Color(0xFFB45309), Color(0x33B45309)],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              profile.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF78350F),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            if (contact.isNotEmpty)
              Text(
                contact,
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 12,
                  color: const Color(0xFF92400E),
                ),
              ),
            if (social.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                social,
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 11.5,
                  color: const Color(0xFF92400E),
                ),
              ),
            ],
            const SizedBox(height: 22),
            _rule(),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Builder(
                builder: (context) {
                  final slots =
                      profile.sectionOrder.where((s) => slotShouldRender(profile, s)).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < slots.length; i++) ...[
                        Text(
                          effectiveSectionTitle(slots[i]),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF78350F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: buildSlotBody(profile, slots[i], slotTheme),
                        ),
                        if (i < slots.length - 1) ...[
                          const SizedBox(height: 20),
                          _rule(),
                          const SizedBox(height: 18),
                        ],
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rule() {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x00D97706), Color(0x66D97706), Color(0x00D97706)],
        ),
      ),
    );
  }
}
