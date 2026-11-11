/// Interface abstraite pour planifier / annuler les rappels de départ.
///
/// Abstrait flutter_local_notifications afin que les tests n'aient besoin
/// d'aucun plugin natif.
abstract interface class ReminderScheduler {
  /// Planifie un rappel local à [scheduledTime] (UTC).
  ///
  /// [id] est un entier déterministe dérivé du bookingId.
  /// [title] et [body] sont déjà localisés par l'appelant.
  /// [payload] est la route go_router à ouvrir au toucher (ex. '/passenger/trips').
  ///
  /// Si [scheduledTime] est dans le passé ou dans moins d'une minute,
  /// la méthode retourne immédiatement sans planifier.
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  });

  /// Annule le rappel associé à [id].
  Future<void> cancel(int id);
}

/// Dérive un identifiant entier déterministe à partir d'un bookingId (String).
/// Utilise le même masque 31 bits que le reste du projet.
int reminderIdForBooking(String bookingId) => bookingId.hashCode & 0x7fffffff;
