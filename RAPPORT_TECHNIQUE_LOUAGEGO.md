# Rapport technique pédagogique — LouageGo

## 1. Présentation générale

LouageGo est une application mobile de réservation de louages en Tunisie.
Elle est développée avec **Flutter** et **Dart**.

L'application permet notamment de :

- créer un compte et se connecter ;
- rechercher un trajet et une station ;
- consulter les horaires, les prix et les places disponibles ;
- enregistrer des favoris ;
- réserver des places ;
- consulter un ticket QR ;
- consulter et annuler ses réservations ;
- recevoir des notifications locales.

La version actuelle est principalement une **application locale de démonstration**.
Les informations sont stockées sur l'appareil avec Hive. Il n'y a pas encore de
serveur métier distant qui synchronise les utilisateurs, les trajets et les
réservations entre plusieurs téléphones.

---

## 2. Flutter expliqué simplement

### 2.1 Qu'est-ce que Flutter ?

Flutter est un framework créé par Google pour construire des interfaces
utilisateur avec un seul code source.

Avec Flutter, le même projet peut produire une application Android, iOS, Web,
Windows, macOS ou Linux. Le projet LouageGo utilise principalement :

- **Dart** : le langage de programmation ;
- **Flutter** : les composants d'interface et le moteur graphique ;
- **packages Flutter** : des bibliothèques spécialisées ajoutées au projet.

Les dépendances du projet sont déclarées dans
[pubspec.yaml](./pubspec.yaml). Par exemple :

```yaml
flutter_riverpod: ^3.4.3
go_router: ^18.0.2
hive_ce: ^2.20.1
qr_flutter: ^4.1.0
```

### 2.2 Comment Flutter construit un écran ?

Dans Flutter, l'interface est un arbre de widgets.

```dart
return Scaffold(
  appBar: AppBar(title: const Text('LouageGo')),
  body: const Center(
    child: Text('Bonjour'),
  ),
);
```

- `Scaffold` représente la structure générale d'une page ;
- `AppBar` représente la barre supérieure ;
- `Center` centre son enfant ;
- `Text` affiche un texte.

Un widget décrit ce qui doit être affiché. Quand les données changent, Flutter
reconstruit la partie nécessaire de l'arbre.

### 2.3 `StatelessWidget` et `StatefulWidget`

Un `StatelessWidget` ne possède pas d'état local qui change pendant sa vie :

```dart
class TitleLabel extends StatelessWidget {
  const TitleLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('LouageGo');
  }
}
```

Un `StatefulWidget` possède un état local. Dans le module 3, l'écran de
réservation utilise un état pour mémoriser les sièges sélectionnés et le mode
de paiement :

```dart
final _selected = <int>{};
String _payment = 'cash';
Booking? _confirmed;
```

`setState` indique à Flutter qu'il faut reconstruire l'écran :

```dart
setState(() {
  value ? _selected.add(seat) : _selected.remove(seat);
});
```

### 2.4 Le point de démarrage

Le programme commence dans [main.dart](./lib/main.dart) :

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: LouageGoApp()));
}
```

Le démarrage :

1. prépare Flutter ;
2. initialise le stockage local Hive ;
3. installe `ProviderScope` pour rendre Riverpod disponible ;
4. lance le widget racine `LouageGoApp`.

---

## 3. Architecture générale du projet

La structure principale est :

```text
lib/
  core/
  features/
  models/
  l10n/
  main.dart
```

### 3.1 Dossier `core`

`core` contient les éléments communs à plusieurs modules. Ce ne sont pas des
fonctionnalités métier spécifiques au passager ou au chauffeur.

Exemples :

```text
core/
  router/       Navigation et protection des routes
  services/     Notifications et localisation
  storage/      Initialisation Hive et données de démonstration
  theme/        Couleurs, thème clair/sombre, préférences
  widgets/      Boutons, cartes et composants réutilisables
```

Fichiers importants :

- [app_router.dart](./lib/core/router/app_router.dart) : définit les URLs et
  les redirections selon l'utilisateur connecté et son rôle ;
- [hive_service.dart](./lib/core/storage/hive_service.dart) : ouvre les boxes
  Hive ;
- [seed_data.dart](./lib/core/storage/seed_data.dart) : ajoute des données de
  démonstration au premier démarrage ;
- [notification_service.dart](./lib/core/services/notification_service.dart) :
  définit le contrat des notifications ;
- [location_service.dart](./lib/core/services/location_service.dart) :
  centralise l'accès au GPS ;
- `core/widgets/` : composants visuels réutilisables.

### 3.2 Dossier `features`

Chaque sous-dossier de `features` correspond à une fonctionnalité métier :

```text
features/
  auth/           Authentification
  search/         Recherche de trajets et stations
  booking/        Réservation
  favorites/      Favoris
  reviews/        Avis et notes
  driver/         Espace chauffeur
  notifications/  Notifications
  profile/        Profil
  support/        Assistance
  legal/          Conditions et confidentialité
```

Cette organisation évite de mélanger tout le code dans un seul dossier.

### 3.3 Dossier `models`

`models` contient les objets qui représentent les données de l'application :

```text
models/
  app_user.dart
  station.dart
  route_line.dart
  louage.dart
  trip.dart
  booking.dart
  payment.dart
  review.dart
  favorite.dart
  app_notification.dart
```

Un modèle contient principalement des propriétés et des fonctions de
conversion, par exemple `toMap` et `fromMap`, afin de sauvegarder les données
dans Hive.

### 3.4 Dossier `l10n`

`l10n` contient les traductions françaises, anglaises et arabes.

```text
l10n/
  app_fr.arb
  app_en.arb
  app_ar.arb
  generated/
```

Les fichiers `generated/` sont générés à partir des fichiers `.arb`. Une chaîne
visible par l'utilisateur devrait idéalement être ajoutée dans ces fichiers
plutôt qu'écrite directement dans un écran.

---

## 4. Organisation interne d'une feature

La feature `booking` est organisée ainsi :

```text
features/booking/
  domain/
    booking_repository.dart
  data/
    hive_booking_repository.dart
  presentation/
    providers/
      booking_provider.dart
    screens/
      booking_flow_screen.dart
      booking_history_screen.dart
```

### 4.1 `domain`

Le dossier `domain` décrit les règles et contrats métier sans imposer une
technologie de stockage.

`booking_repository.dart` dit ce que le module sait faire :

```dart
abstract interface class BookingRepository {
  Stream<List<Booking>> watchForUser(String userId);

  Future<Booking> create({
    required String userId,
    required String tripId,
    required List<int> seats,
    required String paymentMethod,
  });

  Future<Booking> cancel({
    required String bookingId,
    required String userId,
  });
}
```

Ce fichier ne sait pas si les données sont stockées dans Hive, Firebase ou une
API HTTP. Il définit seulement le contrat.

### 4.2 `data`

Le dossier `data` contient l'implémentation concrète du contrat.

Dans le projet, `HiveBookingRepository` implémente le repository avec Hive.
Si un vrai backend est ajouté plus tard, on pourrait créer un autre repository
qui utilise HTTP tout en gardant les mêmes méthodes.

### 4.3 `presentation`

Le dossier `presentation` contient ce que l'utilisateur voit et manipule :

- `screens/` : pages complètes ;
- `widgets/` : composants visuels spécialisés ;
- `providers/` : accès aux données et état consommé par les widgets.

---

## 5. Riverpod expliqué simplement

### 5.1 Qu'est-ce que Riverpod ?

Riverpod est une bibliothèque de gestion d'état et d'injection de dépendances.
Elle permet à un écran de demander des données sans créer lui-même tous les
objets nécessaires.

Sans gestion d'état, chaque écran devrait créer manuellement ses repositories,
écouter les changements et gérer les erreurs. Riverpod centralise ce travail.

### 5.2 Le provider du repository

Dans
[booking_provider.dart](./lib/features/booking/presentation/providers/booking_provider.dart) :

```dart
final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => HiveBookingRepository(
    notifications: ref.read(notificationRepositoryProvider),
  ),
);
```

Ce provider signifie :

> « Quand un écran demande `bookingRepositoryProvider`, donne-lui un
> `HiveBookingRepository` configuré avec le service de notifications. »

L'écran ne dépend donc pas directement de la création de Hive.

### 5.3 Le provider des réservations

```dart
final userBookingsProvider = StreamProvider.autoDispose((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield const [];
    return;
  }
  yield* ref.watch(bookingRepositoryProvider).watchForUser(user.id);
});
```

Ce code :

1. récupère l'utilisateur connecté ;
2. retourne une liste vide si personne n'est connecté ;
3. écoute les réservations de cet utilisateur ;
4. met à jour automatiquement l'écran quand Hive change.

`autoDispose` indique que Riverpod peut libérer cette ressource lorsqu'elle
n'est plus utilisée.

### 5.4 Le `ConsumerWidget`

Un écran qui lit un provider utilise `ConsumerWidget` ou `ConsumerStatefulWidget`.

```dart
class BookingHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(userBookingsProvider);
    // ...
  }
}
```

`ref.watch` observe la donnée. Lorsque la donnée change, l'écran est reconstruit.

---

## 6. Le modèle `Booking`

Fichier :
[booking.dart](./lib/models/booking.dart)

Le modèle représente une réservation sauvegardée :

```dart
class Booking {
  final String id;
  final String userId;
  final String tripId;
  final int seats;
  final double totalPrice;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String qrCode;
  final String departureTime;
}
```

Signification des champs :

- `id` : identifiant unique de la réservation ;
- `userId` : propriétaire de la réservation ;
- `tripId` : trajet réservé ;
- `seats` : nombre de places ;
- `totalPrice` : prix calculé ;
- `status` : `confirmed`, `completed` ou `cancelled` ;
- `paymentMethod` : espèces, carte simulée ou mobile simulé ;
- `paymentStatus` : état du paiement local ;
- `qrCode` : valeur encodée dans le QR ;
- `departureTime` : horaire utilisé notamment pour l'annulation.

### Conversion pour Hive

```dart
Map<String, dynamic> toMap() => {
  'id': id,
  'userId': userId,
  'tripId': tripId,
  'seats': seats,
  'totalPrice': totalPrice,
  'status': status,
  'qrCode': qrCode,
};
```

Hive stocke des maps. `toMap` transforme donc l'objet Dart en données
stockables, et `Booking.fromMap` fait l'opération inverse.

---

## 7. Les fichiers du module 3

### 7.1 `booking_repository.dart`

Chemin :
[lib/features/booking/domain/booking_repository.dart](./lib/features/booking/domain/booking_repository.dart)

Rôle :

- définit la lecture des réservations ;
- définit la création d'une réservation ;
- définit l'annulation ;
- ne contient pas de code d'interface ;
- ne dépend pas directement de Hive.

### 7.2 `hive_booking_repository.dart`

Chemin :
[lib/features/booking/data/hive_booking_repository.dart](./lib/features/booking/data/hive_booking_repository.dart)

Rôle :

- lit et écrit dans `HiveService.bookings` ;
- lit les trajets dans `HiveService.trips` ;
- lit le prix dans `HiveService.routes` ;
- écrit une trace dans `HiveService.payments` ;
- crée des notifications ;
- applique les contrôles métier.

Exemple de validation des places :

```dart
final uniqueSeats = seats.toSet().toList()..sort();
if (uniqueSeats.isEmpty || uniqueSeats.length > trip.freeSeats) {
  throw StateError('Not enough seats');
}
```

Le `Set` supprime les doublons. La vérification est faite dans le repository,
et pas uniquement dans l'interface, car une règle métier doit rester valide
même si l'interface est contournée.

Exemple de calcul du prix :

```dart
totalPrice: route.pricePerSeat * uniqueSeats.length,
```

Le prix est donc calculé avec la donnée du trajet. L'utilisateur ne peut pas
saisir lui-même un prix différent.

Exemple de QR code :

```dart
qrCode: 'LOUAGEGO:$id',
```

Cette valeur n'est pas une donnée bancaire. Elle identifie seulement le ticket
local.

Exemple de mise à jour des places :

```dart
await _trips.put(
  tripId,
  trip.copyWith(
    reservedSeats: trip.reservedSeats + uniqueSeats.length,
  ).toMap(),
);
```

Lors d'une annulation, le nombre réservé est diminué et les places sont
rendues disponibles.

### 7.3 `booking_provider.dart`

Chemin :
[lib/features/booking/presentation/providers/booking_provider.dart](./lib/features/booking/presentation/providers/booking_provider.dart)

Rôle :

- expose le repository aux écrans ;
- expose les réservations de l'utilisateur connecté ;
- expose le contrôleur d'annulation ;
- gère l'état de chargement et d'erreur avec `AsyncValue`.

### 7.4 `booking_flow_screen.dart`

Chemin :
[lib/features/booking/presentation/screens/booking_flow_screen.dart](./lib/features/booking/presentation/screens/booking_flow_screen.dart)

Rôle :

- affiche le trajet sélectionné ;
- affiche le prix par place ;
- permet de sélectionner des places ;
- propose un paiement simulé ;
- appelle le repository lors de la confirmation ;
- affiche le ticket avec QR code.

Exemple de sélection d'une place :

```dart
ChoiceChip(
  label: Text('$seat'),
  selected: _selected.contains(seat),
  onSelected: seat <= trip.reservedSeats
      ? null
      : (value) => setState(() {
          value ? _selected.add(seat) : _selected.remove(seat);
        }),
);
```

`ChoiceChip` est un composant visuel. Il ne sauvegarde pas la réservation :
il modifie seulement l'état local jusqu'à la confirmation.

Exemple de confirmation :

```dart
final booking = await ref
    .read(bookingRepositoryProvider)
    .create(
      userId: user.id,
      tripId: widget.tripId,
      seats: _selected.toList(),
      paymentMethod: _payment,
    );
```

`ref.read` appelle le repository une fois sans établir un abonnement visuel.

Exemple d'affichage du QR :

```dart
QrImageView(
  data: booking.qrCode,
  size: 220,
);
```

Le package `qr_flutter` transforme le texte en image QR.

### 7.5 `booking_history_screen.dart`

Chemin :
[lib/features/booking/presentation/screens/booking_history_screen.dart](./lib/features/booking/presentation/screens/booking_history_screen.dart)

Rôle :

- observe `userBookingsProvider` ;
- affiche les réservations du compte connecté ;
- affiche leur statut et leur prix ;
- propose l'annulation ;
- affiche une erreur si la règle des deux heures interdit l'annulation.

Une réservation est liée à son utilisateur avec `userId`. L'écran demande
toujours l'utilisateur courant avant d'annuler :

```dart
final user = await ref.read(currentUserProvider.future);
await ref.read(bookingRepositoryProvider).cancel(
  bookingId: id,
  userId: user.id,
);
```

Le repository vérifie également cette relation. La sécurité ne dépend donc pas
uniquement de l'écran.

---

## 8. Parcours utilisateur du module 3

Le parcours est le suivant :

```text
Recherche d'un trajet
        ↓
Détail du louage
        ↓
Bouton Réserver
        ↓
Choix des places
        ↓
Choix du paiement simulé
        ↓
Calcul et confirmation
        ↓
Sauvegarde Booking + Payment
        ↓
Mise à jour des places
        ↓
Notification locale
        ↓
Ticket QR
        ↓
Historique des réservations
```

La navigation vers la réservation est déclarée dans
[app_router.dart](./lib/core/router/app_router.dart), et le bouton de détail
est activé dans
[louage_detail_screen.dart](./lib/features/search/presentation/screens/louage_detail_screen.dart).

---

## 9. Où est le frontend ?

Le frontend est principalement dans :

```text
lib/features/*/presentation/
lib/core/widgets/
lib/core/theme/
lib/core/router/
```

Le frontend comprend :

- les écrans ;
- les boutons ;
- les listes ;
- les formulaires ;
- les messages ;
- la navigation ;
- les couleurs et thèmes ;
- les interactions tactiles.

Par exemple, `BookingFlowScreen` est du frontend : il affiche les sièges et
réagit au clic de l'utilisateur.

Le frontend appelle ensuite Riverpod, puis un repository, pour lire ou modifier
les données.

---

## 10. Où est le backend ?

### Situation actuelle

Il n'y a pas de backend distant complet dans cette version.

Le stockage principal est local :

```text
Téléphone de l'utilisateur
  → Hive boxes
  → repositories
  → providers Riverpod
  → écrans Flutter
```

`HiveService` ouvre notamment les boxes :

- `users`
- `stations`
- `routes`
- `louages`
- `trips`
- `bookings`
- `payments`
- `notifications`

Firebase est présent pour le mécanisme de notifications push, mais il ne
remplace pas actuellement un backend de réservation. Les réservations et les
places ne sont pas synchronisées entre plusieurs appareils.

### Ce qu'il faudrait en production

Une vraie application aurait besoin d'une API et d'une base de données
distante pour :

- partager les places disponibles entre passagers ;
- empêcher deux appareils de réserver la même place ;
- gérer les chauffeurs et les administrateurs ;
- traiter les paiements ;
- valider les QR codes côté serveur ;
- envoyer des notifications ciblées ;
- sauvegarder les données après changement de téléphone.

Dans cette évolution, on pourrait remplacer `HiveBookingRepository` par un
repository HTTP sans modifier fortement les écrans, car l'interface
`BookingRepository` sépare le métier du stockage.

---

## 11. Convention de nommage

Le projet suit principalement les conventions Dart :

### Fichiers

Les fichiers utilisent `snake_case` :

```text
booking_flow_screen.dart
hive_booking_repository.dart
app_router.dart
```

### Classes

Les classes utilisent `PascalCase` :

```dart
class BookingFlowScreen {}
class HiveBookingRepository {}
class Booking {}
```

### Variables et méthodes

Les variables et méthodes utilisent `camelCase` :

```dart
final bookingRepositoryProvider = ...;
Future<void> cancel(String bookingId) {}
```

### Variables privées

Un underscore indique qu'un élément est privé au fichier ou à la classe :

```dart
final _selected = <int>{};
Future<void> _confirm() async {}
```

### Suffixes utilisés

- `Screen` : écran complet ;
- `Widget` : composant visuel ;
- `Provider` : objet Riverpod ;
- `Repository` : accès aux données ;
- `Service` : service technique transversal ;
- `Model` ou nom métier : objet de données ;
- `Entity` : objet métier plus abstrait.

---

## 12. Limites connues du module 3

Le module est adapté à un projet universitaire local, mais il ne constitue pas
encore un système de paiement ou de réservation de production.

- Les paiements sont simulés.
- Aucun numéro de carte n'est demandé ni stocké.
- Il n'y a pas de remboursement bancaire réel.
- Les réservations sont locales à l'appareil.
- La disponibilité n'est pas synchronisée entre plusieurs téléphones.
- Le QR code et sa validation restent locaux ; ils ne sont pas vérifiés par un
  serveur et ne peuvent pas empêcher les doublons entre plusieurs appareils.
- Certains textes du nouvel écran sont encore écrits directement en anglais et
  devraient être déplacés dans les traductions `.arb`.

---

## 13. Module 4 — Gestion chauffeur et louage

Le module chauffeur s'appuie sur les fonctionnalités existantes sous
`lib/features/driver/` et sur l'entité partagée `lib/models/louage.dart`.
L'entité conserve la lecture des anciennes maps Hive (`driverId`, `capacity`,
`currentStationId` et `status`) et expose désormais les informations de
capacité, de modèle, de station, de statut, de note et de trajets effectués.

`HiveLouageRepository` relie le profil du chauffeur aux louages, trajets,
réservations, passagers et avis déjà stockés. Il permet de gérer le statut et
les places disponibles, de lister les trajets et passagers, de calculer les
statistiques et de valider un ticket pour le bon chauffeur et le bon trajet.
Les tickets annulés, invalides ou déjà utilisés sont refusés. Cette validation
est utile pour la démonstration, mais reste locale à l'appareil.

Les écrans de profil louage, trajets, détail des réservations, scan QR et note
moyenne sont accessibles dans l'espace réservé au rôle chauffeur. Les textes
sont définis dans les fichiers ARB français, arabe et anglais. Le package
`mobile_scanner` et la permission caméra Android existaient déjà ; iOS utilise
`NSCameraUsageDescription` pour expliquer l'accès caméra.

---

## 14. Résumé pour une soutenance

Réponse courte possible :

> LouageGo est une application Flutter écrite en Dart. Flutter construit
> l'interface avec des widgets. Les écrans sont organisés par fonctionnalités.
> Riverpod gère l'état et injecte les repositories. Hive joue le rôle de
> stockage local. Le module 3 utilise l'entité `Booking`, un contrat
> `BookingRepository` et une implémentation `HiveBookingRepository`. Le
> passager sélectionne des places, choisit un paiement simulé, confirme la
> réservation, reçoit un ticket QR et peut consulter ou annuler sa réservation.
> Il n'y a pas encore de backend distant complet ; cette version est une
> démonstration locale.

Questions fréquentes :

### Pourquoi utiliser un repository ?

Pour séparer la logique métier du stockage. Aujourd'hui le repository utilise
Hive. Demain, il pourrait utiliser une API sans réécrire tous les écrans.

### Pourquoi vérifier les places dans le repository ?

Parce que l'interface peut être contournée ou devenir obsolète. La règle
importante doit être vérifiée juste avant l'écriture des données.

### Pourquoi le paiement est-il simulé ?

Le projet est académique et ne possède pas de passerelle bancaire. On évite
donc de stocker des données sensibles et de dépendre d'un service payant.

### Pourquoi le backend est-il nécessaire en production ?

Pour partager les disponibilités entre utilisateurs, sécuriser les réservations,
traiter les paiements et garantir qu'une même place ne soit pas vendue deux
fois.

### Quelle est la différence entre `ref.watch` et `ref.read` ?

`ref.watch` écoute une donnée et reconstruit l'interface lorsqu'elle change.
`ref.read` lit ou appelle une dépendance sans écouter ses changements pour
reconstruire l'écran.
