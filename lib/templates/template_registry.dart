import 'package:flutter/material.dart';

import '../models/cv_profile.dart';
import '../models/cv_template_meta.dart';
import 'aurora_ascent_template.dart';
import 'crimson_meridian_template.dart';
import 'golden_epoch_template.dart';
import 'obsidian_forge_template.dart';
import 'sapphire_scholar_template.dart';

Widget buildTemplatePreview(CvTemplateId id, CvProfile profile) {
  switch (id) {
    case CvTemplateId.auroraAscent:
      return AuroraAscentTemplate(profile: profile);
    case CvTemplateId.obsidianForge:
      return ObsidianForgeTemplate(profile: profile);
    case CvTemplateId.crimsonMeridian:
      return CrimsonMeridianTemplate(profile: profile);
    case CvTemplateId.sapphireScholar:
      return SapphireScholarTemplate(profile: profile);
    case CvTemplateId.goldenEpoch:
      return GoldenEpochTemplate(profile: profile);
  }
}
