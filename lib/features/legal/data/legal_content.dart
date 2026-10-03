import '../../../core/app_config.dart';
import '../domain/legal_document.dart';
import '../domain/legal_document_repository.dart';

class LocalizedLegalDocumentRepository implements LegalDocumentRepository {
  const LocalizedLegalDocumentRepository();

  @override
  LegalDocument getDocument(LegalDocumentType type, String languageCode) {
    final language = _content.containsKey(languageCode) ? languageCode : 'fr';
    final sections = _content[language]![type]!;
    return LegalDocument(
      type: type,
      version: AppConfig.legalVersion,
      updatedAt: DateTime.parse(AppConfig.legalUpdatedAt),
      sections: sections
          .map(
            (section) => LegalSection(
              title: _contact(section.title),
              paragraphs: section.paragraphs.map(_contact).toList(),
            ),
          )
          .toList(),
    );
  }

  static String _contact(String text) => text
      .replaceAll('{email}', AppConfig.legalContactEmail)
      .replaceAll('{phone}', AppConfig.legalContactPhone);

  static const Map<String, Map<LegalDocumentType, List<_SectionText>>>
  _content = {
    'fr': {
      LegalDocumentType.terms: [
        _SectionText('1. Objet du service', [
          'LouageGo est une application de démonstration universitaire qui met en relation des passagers et des chauffeurs de louage et facilite la recherche de trajets et de places disponibles.',
          'LouageGo agit comme intermédiaire technique. L’application ne réalise pas elle-même le transport et ne garantit pas la disponibilité d’un trajet.',
        ]),
        _SectionText('2. Rôles et comptes', [
          'Les utilisateurs peuvent disposer d’un rôle passager, chauffeur ou administrateur. Chacun doit fournir des informations exactes, protéger ses identifiants et n’utiliser que son propre compte.',
          'Les chauffeurs peuvent être invités à fournir des informations et documents nécessaires à la vérification de leur profil. Une vérification dans cette version de démonstration ne constitue pas une certification officielle.',
        ]),
        _SectionText('3. Réservations et annulations', [
          'Une demande de réservation dépend des horaires, du nombre de places et des informations affichées pour le trajet. Elle n’est confirmée que lorsque l’application indique explicitement qu’elle est acceptée.',
          'Les réservations peuvent être annulées selon les options et règles présentées dans l’application. Les utilisateurs doivent se présenter à l’heure et respecter les instructions convenues avec le chauffeur.',
        ]),
        _SectionText('4. Paiement', [
          'La version actuelle ne traite pas de paiement bancaire réel et ne stocke aucune donnée de carte bancaire. Toute information de paiement affichée dans une démonstration est indicative et ne constitue pas une transaction.',
        ]),
        _SectionText('5. Usages interdits', [
          'Il est interdit de publier des informations fausses, d’usurper l’identité d’autrui, de contourner les mesures de sécurité, de perturber le service ou d’utiliser l’application à des fins illicites ou discriminatoires.',
          'Les passagers et chauffeurs doivent adopter un comportement respectueux et ne pas proposer ou solliciter un service contraire à la loi.',
        ]),
        _SectionText('6. Disponibilité et responsabilité', [
          'Le service est fourni à titre expérimental, sans garantie de disponibilité continue ni d’exactitude absolue des données locales. LouageGo n’est pas transporteur et ne répond pas de l’exécution du transport par les utilisateurs, sous réserve des responsabilités qui ne peuvent être exclues par la loi.',
          'L’utilisateur reste responsable de vérifier les informations importantes avant le départ.',
        ]),
        _SectionText('7. Suspension et suppression', [
          'Un compte peut être suspendu en cas d’usage abusif, de risque pour les utilisateurs ou de non-respect des présentes conditions. L’utilisateur peut demander la suppression de son compte depuis son profil ; les données associées sont alors supprimées ou anonymisées selon leur nature.',
        ]),
        _SectionText('8. Droit applicable et contact', [
          'Les présentes conditions sont soumises au droit tunisien. Les règles impératives applicables restent réservées.',
          'Contact du responsable de l’application : {email} — {phone}.',
        ]),
      ],
      LegalDocumentType.privacy: [
        _SectionText('1. Responsable et cadre', [
          'Le responsable de cette version de démonstration est l’équipe du projet universitaire LouageGo, joignable à {email} ou {phone}. Le présent texte est fourni à titre informatif et doit être validé par un juriste avant toute publication.',
          'Le traitement est présenté au regard de la loi organique tunisienne n° 2004-63 relative à la protection des données à caractère personnel et des formalités applicables auprès de l’INPDP.',
        ]),
        _SectionText('2. Données concernées', [
          'Selon les fonctions utilisées, l’application peut enregistrer le nom, le numéro de téléphone, l’adresse email, la photo de profil, la ville, le rôle et les informations de compte.',
          'Les profils chauffeur peuvent également contenir des informations de véhicule et des documents communiqués pour la vérification. La position GPS est utilisée uniquement après consentement, afin de rechercher des stations proches. La caméra n’est sollicitée que pour une fonction qui en a besoin, par exemple la lecture d’un QR code. Les notifications dépendent de l’autorisation correspondante.',
          'Cette version ne stocke pas de données de carte bancaire et n’envoie pas de SMS réels.',
        ]),
        _SectionText('3. Finalités et base', [
          'Les données servent à créer et gérer le compte, afficher le profil, rechercher des stations et trajets, gérer les réservations, les favoris et les notifications, assurer la sécurité et répondre aux demandes.',
          'Dans cette version, le traitement repose sur le consentement de l’utilisateur, notamment pour les données facultatives et les permissions de l’appareil. Le consentement de localisation peut être refusé sans empêcher l’utilisation des autres fonctions.',
        ]),
        _SectionText('4. Stockage et destinataires', [
          'Les données de cette version sont stockées localement sur l’appareil dans le stockage de l’application. Elles ne sont pas transmises à Firebase ni à un service distant par cette application de démonstration.',
          'Les personnes autorisées au sein de l’équipe projet peuvent accéder aux données présentes sur l’appareil lors des opérations de test ou de support.',
        ]),
        _SectionText('5. Conservation', [
          'Les données sont conservées sur l’appareil tant que le compte ou l’application est utilisé, ou jusqu’à la suppression du compte ou des données de l’application. Les copies de sauvegarde du système d’exploitation peuvent suivre leurs propres durées.',
        ]),
        _SectionText('6. Vos droits', [
          'Sous réserve des conditions prévues par la loi, vous pouvez demander l’accès à vos données, leur rectification ou leur suppression. La suppression du compte est accessible depuis la page Profil. Vous pouvez également retirer les permissions de localisation, caméra ou notifications dans les réglages de l’appareil.',
          'Pour toute demande ou question relative aux données, contactez le responsable à {email} ou {phone}. Vous pouvez aussi vous adresser à l’INPDP selon les procédures applicables.',
        ]),
        _SectionText('7. Sécurité et évolution', [
          'Des mesures raisonnables sont appliquées dans le périmètre de cette démonstration. Le stockage local signifie que la sécurité de l’appareil, son verrouillage et ses sauvegardes relèvent aussi de l’utilisateur.',
          'Cette politique peut être mise à jour. En cas de modification de version, l’application peut demander à nouveau votre acceptation avant de poursuivre.',
        ]),
      ],
    },
    'en': {
      LegalDocumentType.terms: [
        _SectionText('1. Service purpose', [
          'LouageGo is a university demonstration application that connects shared-taxi passengers and drivers and helps users find trips and available seats.',
          'LouageGo is a technical intermediary. It does not itself provide transportation or guarantee that a trip is available.',
        ]),
        _SectionText('2. Roles and accounts', [
          'Users may have a passenger, driver, or administrator role. Users must provide accurate information, protect their credentials, and use only their own account.',
          'Drivers may be asked to provide profile information and documents for review. A review in this demo is not an official certification.',
        ]),
        _SectionText('3. Bookings and cancellations', [
          'A booking request depends on the schedule, available seats, and trip information shown in the app. It is confirmed only when the app explicitly indicates acceptance.',
          'Bookings may be cancelled using the options and rules shown in the app. Users should arrive on time and follow arrangements made with the driver.',
        ]),
        _SectionText('4. Payments', [
          'The current version does not process real bank payments and does not store bank-card data. Any payment information shown in a demo is indicative and is not a transaction.',
        ]),
        _SectionText('5. Prohibited use', [
          'Users must not submit false information, impersonate others, bypass security measures, disrupt the service, or use the app unlawfully or discriminatorily.',
          'Passengers and drivers must behave respectfully and must not offer or request services contrary to law.',
        ]),
        _SectionText('6. Availability and liability', [
          'The service is experimental and is provided without a guarantee of continuous availability or absolute accuracy of local data. LouageGo is not a carrier and is not responsible for transportation performed by users, subject to liabilities that cannot be excluded by law.',
          'Users remain responsible for checking important trip information before departure.',
        ]),
        _SectionText('7. Suspension and deletion', [
          'An account may be suspended for misuse, risks to users, or breach of these terms. Users may request account deletion from their profile; associated data will be deleted or anonymized as appropriate.',
        ]),
        _SectionText('8. Governing law and contact', [
          'These terms are governed by Tunisian law, without prejudice to mandatory applicable rules.',
          'Application contact: {email} — {phone}.',
        ]),
      ],
      LegalDocumentType.privacy: [
        _SectionText('1. Controller and framework', [
          'The controller for this demo version is the LouageGo university project team, reachable at {email} or {phone}. This text is informational and must be reviewed by legal counsel before publication.',
          'This notice is framed with reference to Tunisian Organic Law No. 2004-63 on the protection of personal data and applicable INPDP procedures.',
        ]),
        _SectionText('2. Data involved', [
          'Depending on the features used, the app may store your name, phone number, email address, profile photo, city, role, and account information.',
          'Driver profiles may also contain vehicle details and documents submitted for review. GPS location is used only with consent to find nearby stations. The camera is requested only for a feature that needs it, such as QR scanning. Notifications depend on the relevant device permission.',
          'This version does not store bank-card data and does not send real SMS messages.',
        ]),
        _SectionText('3. Purposes and legal basis', [
          'Data is used to create and manage accounts, display profiles, find stations and trips, manage bookings, favourites and notifications, protect the service, and respond to requests.',
          'In this version, processing is based on user consent, including for optional data and device permissions. Location consent may be refused without preventing use of other features.',
        ]),
        _SectionText('4. Storage and recipients', [
          'Data in this version is stored locally on the device in the application storage. This demo does not send it to Firebase or a remote service.',
          'Authorized project team members may access data on the device while testing or providing support.',
        ]),
        _SectionText('5. Retention', [
          'Data remains on the device while the account or app is used, until the account is deleted, or until application data is removed. Operating-system backups may have their own retention periods.',
        ]),
        _SectionText('6. Your rights', [
          'Subject to applicable legal conditions, you may request access, correction, or deletion of your data. Account deletion is available from the Profile page. You can also revoke location, camera, or notification permissions in device settings.',
          'For privacy requests, contact the controller at {email} or {phone}. You may also contact the INPDP through applicable procedures.',
        ]),
        _SectionText('7. Security and changes', [
          'Reasonable measures are applied within the scope of this demo. Because data is stored locally, device security, locking, and backups are also the user’s responsibility.',
          'This notice may change. If its version changes, the app may ask for renewed acceptance before you continue.',
        ]),
      ],
    },
    'ar': {
      LegalDocumentType.terms: [
        _SectionText('1. غرض الخدمة', [
          'لواج غو تطبيق تجريبي جامعي يربط بين ركاب سيارات الأجرة المشتركة والسائقين ويساعد على البحث عن الرحلات والمقاعد المتاحة.',
          'تعمل لواج غو كوسيط تقني. ولا توفر النقل بنفسها ولا تضمن توفر أي رحلة.',
        ]),
        _SectionText('2. الأدوار والحسابات', [
          'يمكن أن يكون للمستخدم دور راكب أو سائق أو مسؤول. يجب تقديم معلومات صحيحة وحماية بيانات الدخول واستخدام الحساب الشخصي فقط.',
          'قد يُطلب من السائقين تقديم معلومات ووثائق لمراجعة ملفاتهم. ولا تمثل المراجعة في هذه النسخة التجريبية اعتمادًا رسميًا.',
        ]),
        _SectionText('3. الحجوزات والإلغاء', [
          'يعتمد طلب الحجز على الجدول والمقاعد المتاحة ومعلومات الرحلة المعروضة. ولا يُعد الحجز مؤكدًا إلا عندما يوضح التطبيق قبوله صراحةً.',
          'يمكن إلغاء الحجوزات وفق الخيارات والقواعد المعروضة في التطبيق. ينبغي للمستخدمين الحضور في الوقت واحترام الترتيبات المتفق عليها مع السائق.',
        ]),
        _SectionText('4. الدفع', [
          'لا تعالج النسخة الحالية مدفوعات مصرفية حقيقية ولا تخزن بيانات البطاقات. وأي معلومات دفع تظهر في العرض التجريبي إرشادية ولا تمثل معاملة.',
        ]),
        _SectionText('5. الاستخدامات المحظورة', [
          'يُحظر تقديم معلومات زائفة أو انتحال هوية الغير أو تجاوز تدابير الأمان أو تعطيل الخدمة أو استخدام التطبيق لأغراض مخالفة للقانون أو تمييزية.',
          'يجب على الركاب والسائقين التصرف باحترام وعدم عرض أو طلب خدمة مخالفة للقانون.',
        ]),
        _SectionText('6. التوفر والمسؤولية', [
          'الخدمة تجريبية ولا نضمن استمرار توفرها أو الدقة المطلقة للبيانات المحلية. لواج غو ليست ناقلًا ولا تتحمل مسؤولية تنفيذ النقل من قبل المستخدمين، مع مراعاة المسؤوليات التي لا يجوز استبعادها قانونًا.',
          'يبقى المستخدم مسؤولًا عن التحقق من المعلومات المهمة قبل المغادرة.',
        ]),
        _SectionText('7. تعليق الحساب وحذفه', [
          'يجوز تعليق الحساب عند إساءة الاستخدام أو وجود خطر على المستخدمين أو مخالفة هذه الشروط. ويمكن طلب حذف الحساب من صفحة الملف الشخصي، ثم تُحذف البيانات المرتبطة أو تُجهّل بحسب طبيعتها.',
        ]),
        _SectionText('8. القانون والاتصال', [
          'تخضع هذه الشروط للقانون التونسي، مع مراعاة القواعد الإلزامية المنطبقة.',
          'للتواصل مع فريق التطبيق: {email} — {phone}.',
        ]),
      ],
      LegalDocumentType.privacy: [
        _SectionText('1. المسؤول والإطار القانوني', [
          'المسؤول عن هذه النسخة التجريبية هو فريق مشروع لواج غو الجامعي، ويمكن التواصل معه عبر {email} أو {phone}. هذا النص معلوماتي ويجب أن يراجعه مختص قانوني قبل النشر.',
          'أُعد هذا الإشعار بالاستناد إلى القانون الأساسي التونسي عدد 63 لسنة 2004 المتعلق بحماية المعطيات الشخصية والإجراءات المنطبقة لدى الهيئة الوطنية لحماية المعطيات الشخصية.',
        ]),
        _SectionText('2. البيانات المعنية', [
          'بحسب الوظائف المستخدمة، قد يخزن التطبيق الاسم ورقم الهاتف والبريد الإلكتروني وصورة الملف الشخصي والمدينة والدور ومعلومات الحساب.',
          'قد تتضمن ملفات السائقين أيضًا معلومات المركبة والوثائق المقدمة للمراجعة. لا يُستخدم موقع GPS إلا بعد الموافقة للعثور على المحطات القريبة. ولا تُطلب الكاميرا إلا لوظيفة تحتاجها مثل قراءة رمز QR. وتتطلب الإشعارات الإذن المناسب من الجهاز.',
          'لا تخزن هذه النسخة بيانات البطاقات المصرفية ولا ترسل رسائل SMS حقيقية.',
        ]),
        _SectionText('3. الأغراض والأساس', [
          'تُستخدم البيانات لإنشاء الحساب وإدارته وعرض الملف الشخصي والبحث عن المحطات والرحلات وإدارة الحجوزات والمفضلة والإشعارات وحماية الخدمة والرد على الطلبات.',
          'تعتمد المعالجة في هذه النسخة على موافقة المستخدم، بما في ذلك البيانات الاختيارية وأذونات الجهاز. ويمكن رفض مشاركة الموقع دون منع استخدام الوظائف الأخرى.',
        ]),
        _SectionText('4. التخزين والجهات التي يمكنها الوصول', [
          'تُخزن بيانات هذه النسخة محليًا على الجهاز ضمن مساحة التطبيق، ولا ترسلها النسخة التجريبية إلى Firebase أو خدمة بعيدة.',
          'قد يتمكن أعضاء فريق المشروع المصرح لهم من الوصول إلى البيانات الموجودة على الجهاز أثناء الاختبار أو الدعم.',
        ]),
        _SectionText('5. مدة الاحتفاظ', [
          'تبقى البيانات على الجهاز ما دام الحساب أو التطبيق مستخدمًا، أو إلى حين حذف الحساب أو بيانات التطبيق. وقد تخضع النسخ الاحتياطية لنظام التشغيل لمدد احتفاظ مستقلة.',
        ]),
        _SectionText('6. حقوقك', [
          'وفق الشروط القانونية المنطبقة، يمكنك طلب الاطلاع على بياناتك أو تصحيحها أو حذفها. يتوفر حذف الحساب من صفحة الملف الشخصي. ويمكنك أيضًا إلغاء أذونات الموقع أو الكاميرا أو الإشعارات من إعدادات الجهاز.',
          'للاستفسارات والطلبات المتعلقة بالخصوصية، اتصل بالمسؤول عبر {email} أو {phone}. ويمكنك كذلك الاتصال بالهيئة الوطنية لحماية المعطيات الشخصية وفق الإجراءات المعمول بها.',
        ]),
        _SectionText('7. الأمان والتعديلات', [
          'تُطبق تدابير معقولة ضمن نطاق هذا العرض التجريبي. وبما أن البيانات محلية، تقع مسؤولية أمان الجهاز وقفل الشاشة والنسخ الاحتياطية على المستخدم أيضًا.',
          'قد تُحدّث هذه السياسة. وعند تغيير إصدارها، قد يطلب التطبيق موافقة جديدة قبل المتابعة.',
        ]),
      ],
    },
  };
}

class _SectionText {
  const _SectionText(this.title, this.paragraphs);

  final String title;
  final List<String> paragraphs;
}
