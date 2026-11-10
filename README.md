<div align="center">

# 🚕 LouageGo

### La réservation de louages en Tunisie, simplement.

**Une application mobile Flutter pour découvrir des trajets et faciliter la réservation de louages, avec des espaces dédiés aux passagers et aux chauffeurs.**

[![Flutter](https://img.shields.io/badge/Flutter-mobile-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.13.3%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Plateformes](https://img.shields.io/badge/Plateformes-Android%20%7C%20iOS-20A779?style=for-the-badge)](#)
[![Université](https://img.shields.io/badge/Université-Esprit-EA6A2A?style=for-the-badge)](#)

📍 **Projet universitaire · Module Application Mobile · Classe 5SAE7**

</div>

---

## 📖 À propos du projet

**LouageGo** est une application mobile conçue pour rendre la recherche et la réservation de trajets en louage plus accessibles en Tunisie. Elle propose une expérience pensée pour les deux principaux utilisateurs de la plateforme : les **passagers**, qui recherchent un trajet, et les **chauffeurs**, qui gèrent leur activité.

Développé dans le cadre du **module Application Mobile** à **Esprit**, ce projet met en pratique la création d'une application avec Flutter et Dart : organisation en écrans et services, gestion de données locales, notifications et conception d'interfaces adaptées au mobile.

### 🎯 Objectifs

- Simplifier la recherche de trajets en louage.
- Faciliter la mise en relation entre passagers et chauffeurs.
- Proposer une application mobile claire et facile à utiliser.
- Mettre en pratique les compétences de développement mobile acquises durant le module.

### 📱 Modules de l'application

| Module | Description |
| --- | --- |
| 🔐 **Authentification** | Écrans d'accès et gestion de la session utilisateur. |
| 🧳 **Espace passager** | Parcours destiné aux passagers pour consulter et réserver des trajets. |
| 🚘 **Espace chauffeur** | Parcours dédié aux chauffeurs et à la gestion de leurs trajets. |
| 🔔 **Notifications** | Prise en charge des notifications push Android via Firebase Cloud Messaging (FCM). |
| 💾 **Données locales** | Stockage local avec Hive et données de démonstration au premier lancement. |

> Les fonctionnalités de réservation et les données de démonstration sont présentées dans le cadre du projet. L'envoi de notifications ciblées à un utilisateur ou à un rôle nécessite un backend de confiance.

---

## 👥 Équipe du projet

**Université :** Esprit  
**Classe :** 5SAE7  
**Module :** Application Mobile

| Membre |
| --- |
| 👩‍💻 Islem Bouchaala |
| 👩‍💻 Bouthayna Hammemi |
| 👩‍💻 Sourour Alaimi |
| 👨‍💻 Hazem Ouasli |
| 👩‍💻 Islem Raissi |

---

## ✨ Fonctionnalités et technologies

- 🧭 Écrans dédiés à l'authentification, aux passagers et aux chauffeurs.
- 🗃️ Persistance locale des données avec **Hive**.
- 🔔 Notifications push Android avec **Firebase Cloud Messaging**.
- 📲 Application développée avec **Flutter** et **Dart**.
- 🤖 Configuration des plateformes **Android** et **iOS**.

---

## 🛠️ Prérequis

- Flutter SDK avec Dart `3.13.3` ou supérieur.
- Android Studio et Android SDK pour exécuter l'application sur Android.
- Un émulateur configuré ou un appareil Android connecté.
- Git.

Vérifiez votre installation avec :

```bash
flutter doctor
```

## 🚀 Installation et lancement

Depuis la racine du projet :

```bash
git clone https://github.com/BouthaynaHammami/Louage_Go.git
cd Louage_Go
flutter pub get
flutter run
```

Les données sont stockées localement avec Hive. Les boxes sont initialisées au démarrage et des louages de démonstration sont ajoutés lors du premier lancement.

## 🔔 Tester une notification push Android

1. Lancez l'application sur un téléphone Android ou un émulateur avec une image Google Play, puis autorisez les notifications dans les paramètres.
2. En développement, récupérez le token FCM conservé dans la box Hive `session`, sous la clé `fcmToken` (un outil de débogage Hive peut être utilisé).
3. Dans la console Firebase du projet **louage-go**, ouvrez **Messaging → Nouvelle campagne → Notifications** et envoyez une notification de test au token, ou ciblez le topic `all`.
4. Pour tester la navigation au toucher, ajoutez la donnée personnalisée `route: /notifications`. Vérifiez le comportement lorsque l'application est au premier plan, en arrière-plan et fermée.

La console Firebase convient aux essais manuels. L'envoi ciblé à un utilisateur ou à un rôle doit passer par un backend de confiance, par exemple Cloud Functions ; l'application ne doit pas contenir de clés serveur Firebase.

## ✉️ Envoi du billet par e-mail (Brevo)

L'application peut envoyer le billet PDF avec l'API transactionnelle Brevo v3. Configurez la clé API et l'adresse d'expéditeur vérifiée uniquement au lancement :

```bash
flutter run --dart-define=BREVO_API_KEY=xxx --dart-define=BREVO_SENDER_EMAIL=expediteur@verifie.com
```

Le nom d'expéditeur peut être remplacé avec `--dart-define=BREVO_SENDER_NAME=LouageGo`. L'adresse d'expéditeur doit être validée dans le compte Brevo. Les clés API Brevo peuvent expirer après 90 jours d'inactivité ; renouvelez-les selon les règles de votre compte. Ne commitez jamais de clé API ni de fichier `.env`.

Cette intégration directe sert uniquement au développement et à la démonstration : une application mobile distribuée peut être inspectée, donc toute clé `--dart-define` intégrée au binaire peut être extraite. En production, l'application doit transmettre la demande à un backend de confiance (par exemple une Cloud Function), qui garde la clé Brevo côté serveur et applique les contrôles d'accès et de quota.

## 🗂️ Structure du projet

```text
lib/
├── core/       Thème et éléments communs
├── models/     Modèles de données
├── screens/    Écrans d'authentification, passager et chauffeur
├── services/   Services applicatifs
└── widgets/    Widgets réutilisables
test/           Tests Flutter
android/        Configuration de la plateforme Android
ios/            Configuration de la plateforme iOS
```

## 🧪 Tests

Pour exécuter les tests Flutter :

```bash
flutter test
```

## 📚 Ressources

- [Documentation Flutter](https://docs.flutter.dev/)
- [Documentation Dart](https://dart.dev/guides)

---

<div align="center">

**LouageGo · Esprit · 5SAE7**  
_Fait avec Flutter et beaucoup de collaboration_ 💙

</div>
