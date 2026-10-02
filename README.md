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

Les données de l'application sont stockées localement avec Hive. Les boxes sont initialisées au démarrage et des louages de démonstration sont ajoutés automatiquement lors du premier lancement. Aucune configuration Firebase n'est nécessaire.

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
