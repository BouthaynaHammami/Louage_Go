enum LegalDocumentType { terms, privacy }

class LegalSection {
  const LegalSection({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;
}

class LegalDocument {
  const LegalDocument({
    required this.type,
    required this.version,
    required this.updatedAt,
    required this.sections,
  });

  final LegalDocumentType type;
  final String version;
  final DateTime updatedAt;
  final List<LegalSection> sections;
}
