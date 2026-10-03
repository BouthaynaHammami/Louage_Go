import 'legal_document.dart';

abstract interface class LegalDocumentRepository {
  LegalDocument getDocument(LegalDocumentType type, String languageCode);
}
