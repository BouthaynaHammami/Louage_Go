import 'model_map.dart';

enum LouageStatus { disponible, enAttente, enDeplacement, horsService }

class Louage {
  final String id;
  final String chauffeurId;
  final String matricule;
  final String modele;
  final int placesTotal;
  final int placesDisponibles;
  final String stationActuelle;
  final LouageStatus statut;
  final double noteMoyenne;
  final int nombreTrajets;
  final bool isQueued;

  const Louage({
    this.id = '',
    String chauffeurId = '',
    String? driverId,
    this.matricule = '',
    this.modele = '',
    int placesTotal = 8,
    int? capacity,
    int? placesDisponibles,
    String stationActuelle = '',
    String? currentStationId,
    this.statut = LouageStatus.disponible,
    this.noteMoyenne = 0,
    this.nombreTrajets = 0,
    this.isQueued = false,
  }) : chauffeurId = driverId ?? chauffeurId,
       placesTotal = capacity ?? placesTotal,
       placesDisponibles = placesDisponibles ?? capacity ?? placesTotal,
       stationActuelle = currentStationId ?? stationActuelle;

  String get driverId => chauffeurId;
  int get capacity => placesTotal;
  String get currentStationId => stationActuelle;

  String get status => switch (statut) {
    LouageStatus.disponible => 'active',
    LouageStatus.enAttente => 'waiting',
    LouageStatus.enDeplacement => 'departed',
    LouageStatus.horsService => 'inactive',
  };

  void validate() {
    if (matricule.trim().isEmpty) {
      throw const FormatException('Le matricule du louage est obligatoire.');
    }
    if (placesTotal < 1 ||
        placesDisponibles < 0 ||
        placesDisponibles > placesTotal) {
      throw const FormatException(
        'Les places disponibles doivent être comprises entre 0 et la capacité.',
      );
    }
    if (noteMoyenne < 0 || noteMoyenne > 5 || nombreTrajets < 0) {
      throw const FormatException('Les statistiques du louage sont invalides.');
    }
  }

  Louage copyWith({
    String? id,
    String? chauffeurId,
    String? driverId,
    String? matricule,
    String? modele,
    int? placesTotal,
    int? capacity,
    int? placesDisponibles,
    String? stationActuelle,
    String? currentStationId,
    LouageStatus? statut,
    double? noteMoyenne,
    int? nombreTrajets,
    bool? isQueued,
  }) => Louage(
    id: id ?? this.id,
    chauffeurId: driverId ?? chauffeurId ?? this.chauffeurId,
    matricule: matricule ?? this.matricule,
    modele: modele ?? this.modele,
    placesTotal: capacity ?? placesTotal ?? this.placesTotal,
    placesDisponibles: placesDisponibles ?? this.placesDisponibles,
    stationActuelle: currentStationId ?? stationActuelle ?? this.stationActuelle,
    statut: statut ?? this.statut,
    noteMoyenne: noteMoyenne ?? this.noteMoyenne,
    nombreTrajets: nombreTrajets ?? this.nombreTrajets,
    isQueued: isQueued ?? this.isQueued,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'chauffeurId': chauffeurId,
    'driverId': chauffeurId,
    'matricule': matricule,
    'modele': modele,
    'placesTotal': placesTotal,
    'placesDisponibles': placesDisponibles,
    'capacity': placesTotal,
    'stationActuelle': stationActuelle,
    'currentStationId': stationActuelle,
    'statut': statut.name,
    'status': status,
    'noteMoyenne': noteMoyenne,
    'nombreTrajets': nombreTrajets,
    'isQueued': isQueued,
  };

  factory Louage.fromMap(Map<dynamic, dynamic> map) {
    final legacyStatus = ModelMap.text(map, 'status', 'active');
    final status = LouageStatus.values.firstWhere(
      (value) => value.name == ModelMap.text(map, 'statut'),
      orElse: () => switch (legacyStatus) {
        'waiting' => LouageStatus.enAttente,
        'departed' => LouageStatus.enDeplacement,
        'inactive' || 'outOfService' => LouageStatus.horsService,
        _ => LouageStatus.disponible,
      },
    );
    return Louage(
      id: ModelMap.text(map, 'id'),
      chauffeurId: ModelMap.text(map, 'chauffeurId', ModelMap.text(map, 'driverId')),
      matricule: ModelMap.text(map, 'matricule'),
      modele: ModelMap.text(map, 'modele'),
      placesTotal: ModelMap.integer(
        map,
        'placesTotal',
        ModelMap.integer(map, 'capacity', 8),
      ),
      placesDisponibles: ModelMap.integer(
        map,
        'placesDisponibles',
        ModelMap.integer(map, 'capacity', 8),
      ),
      stationActuelle: ModelMap.text(
        map,
        'stationActuelle',
        ModelMap.text(map, 'currentStationId'),
      ),
      statut: status,
      noteMoyenne: ModelMap.decimal(map, 'noteMoyenne'),
      nombreTrajets: ModelMap.integer(map, 'nombreTrajets'),
      isQueued: ModelMap.boolean(map, 'isQueued'),
    );
  }
}
