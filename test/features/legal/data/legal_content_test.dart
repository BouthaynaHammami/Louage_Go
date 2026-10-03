import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/features/legal/data/legal_content.dart';
import 'package:louage_go/features/legal/domain/legal_document.dart';

void main() {
  test('unsupported document language falls back to French', () {
    const repository = LocalizedLegalDocumentRepository();

    final french = repository.getDocument(LegalDocumentType.terms, 'fr');
    final fallback = repository.getDocument(LegalDocumentType.terms, 'de');

    expect(fallback.sections.first.title, french.sections.first.title);
    expect(fallback.sections, isNotEmpty);
  });

  test('terms and privacy documents cover their respective subjects', () {
    const repository = LocalizedLegalDocumentRepository();
    final terms = repository.getDocument(LegalDocumentType.terms, 'en');
    final privacy = repository.getDocument(LegalDocumentType.privacy, 'ar');

    expect(terms.sections.length, greaterThanOrEqualTo(7));
    expect(terms.sections.any((section) => section.title.contains('Payments')),
        isTrue);
    expect(privacy.sections.any((section) => section.title.contains('حقوق')),
        isTrue);
  });
}
