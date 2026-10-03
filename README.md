# LouageGo

LouageGo est une application mobile Flutter de réservation de louages en Tunisie. Ce projet universitaire vise à faciliter la recherche et la réservation de trajets pour les passagers, tout en proposant un espace adapté aux chauffeurs.

## Prérequis

- Flutter SDK avec Dart `3.13.3` ou supérieur
- Android Studio et Android SDK pour lancer l'application sur Android
- Un émulateur configuré ou un appareil Android connecté
- Git

Vérifiez l'installation avec `flutter doctor`.

## Installation

Depuis la racine du projet :

```bash
flutter pub get
flutter run
```

Les données de l'application sont stockées localement avec Hive. Les boxes sont initialisées au démarrage et des louages de démonstration sont ajoutés automatiquement lors du premier lancement. Android utilise Firebase Cloud Messaging pour la livraison des notifications push ; Hive reste la source de vérité de la boîte de réception. Si Firebase n'est pas disponible sur une plateforme, l'application continue de fonctionner avec les notifications locales.

## Tester une notification push Android

1. Lancez l'application sur un téléphone Android ou un émulateur avec image Google Play, puis acceptez les notifications dans Paramètres.
2. Récupérez le token FCM stocké localement dans la box `session`, clé `fcmToken` (un outil de débogage Hive peut être utilisé en développement).
3. Dans la console Firebase du projet **louage-go**, ouvrez **Messaging → Nouvelle campagne → Notifications** et envoyez un message test au token, ou ciblez le topic `all`.
4. Pour tester une navigation au toucher, incluez les données personnalisées `route: /notifications`. Vérifiez la réception en premier plan, en arrière-plan et application fermée.

La console Firebase convient aux essais manuels. L'envoi ciblé à un utilisateur ou à un rôle nécessite un backend de confiance (par exemple Cloud Functions) ; l'application ne contient volontairement aucune clé serveur ni logique d'envoi ciblé.

## Structure

```text
lib/
	core/       Thème et éléments communs
	models/     Modèles de données
	screens/    Écrans d'authentification, passager et chauffeur
	services/   Services applicatifs
	widgets/    Widgets réutilisables
test/         Tests Flutter
android/      Configuration de la plateforme Android
ios/          Configuration de la plateforme iOS
```

## Technologies

- Flutter et Dart
- Android et iOS

Pour la documentation Flutter, consultez [docs.flutter.dev](https://docs.flutter.dev/).
