import 'model_map.dart';

class DriverProfile {
  final String userId;
  final String licenseNo;
  final String carteGrise;
  final String assurance;
  final String matricule;
  final String vehiclePhoto;
  final String validationStatus;
  final double ratingAverage;

  const DriverProfile({
    this.userId = '',
    this.licenseNo = '',
    this.carteGrise = '',
    this.assurance = '',
    this.matricule = '',
    this.vehiclePhoto = '',
    this.validationStatus = 'pending',
    this.ratingAverage = 0,
  });

  DriverProfile copyWith({
    String? userId,
    String? licenseNo,
    String? carteGrise,
    String? assurance,
    String? matricule,
    String? vehiclePhoto,
    String? validationStatus,
    double? ratingAverage,
  }) =>
      DriverProfile(
        userId: userId ?? this.userId,
        licenseNo: licenseNo ?? this.licenseNo,
        carteGrise: carteGrise ?? this.carteGrise,
        assurance: assurance ?? this.assurance,
        matricule: matricule ?? this.matricule,
        vehiclePhoto: vehiclePhoto ?? this.vehiclePhoto,
        validationStatus: validationStatus ?? this.validationStatus,
        ratingAverage: ratingAverage ?? this.ratingAverage,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'licenseNo': licenseNo,
        'carteGrise': carteGrise,
        'assurance': assurance,
        'matricule': matricule,
        'vehiclePhoto': vehiclePhoto,
        'validationStatus': validationStatus,
        'ratingAverage': ratingAverage,
      };

  factory DriverProfile.fromMap(Map<dynamic, dynamic> map) => DriverProfile(
        userId: ModelMap.text(map, 'userId'),
        licenseNo: ModelMap.text(map, 'licenseNo'),
        carteGrise: ModelMap.text(map, 'carteGrise'),
        assurance: ModelMap.text(map, 'assurance'),
        matricule: ModelMap.text(map, 'matricule'),
        vehiclePhoto: ModelMap.text(map, 'vehiclePhoto'),
        validationStatus: ModelMap.text(map, 'validationStatus', 'pending'),
        ratingAverage: ModelMap.decimal(map, 'ratingAverage'),
      );
}