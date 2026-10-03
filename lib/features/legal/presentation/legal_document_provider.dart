import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/legal_content.dart';
import '../domain/legal_document_repository.dart';

final legalDocumentRepositoryProvider = Provider<LegalDocumentRepository>(
  (ref) => const LocalizedLegalDocumentRepository(),
);
