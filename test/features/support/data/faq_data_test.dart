import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/features/support/data/faq_data.dart';
import 'package:louage_go/features/support/presentation/screens/support_faq_screen.dart';

void main() {
  test('FAQ search normalization ignores French accents', () {
    expect(normalizeFaqText('Réservation et trajet'), 'reservation et trajet');
    expect(
      supportFaq['fr']!.where(
        (entry) => normalizeFaqText(entry.question).contains('rechercher'),
      ),
      isNotEmpty,
    );
  });

  test('FAQ editorial data is complete in each supported language', () {
    for (final language in ['fr', 'en', 'ar']) {
      expect(supportFaq[language], hasLength(13));
      expect(supportFaq[language]!.map((entry) => entry.category).toSet(), {
        'booking',
        'payment',
        'trip',
        'account',
        'drivers',
      });
    }
  });
}
