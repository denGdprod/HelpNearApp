class MedicalData {
  final String gender; // 'male' или 'female'
  final String bloodGroup; // например 'O(I) Rh+', 'A(II) Rh-'
  final double weight; // в кг
  final List<String> disabilities; // например ['hearing', 'vision']
  final bool isPregnant;
  final bool hasDiabetes;
  final bool hasAsthma;
  final bool hasHeartFailure;
  final bool hasMobilityIssues;
  final bool hasCancer;
  final String otherDiseases;
  
  MedicalData({
    required this.gender,
    required this.bloodGroup,
    required this.weight,
    required this.disabilities,
    required this.isPregnant,
    required this.hasDiabetes,
    required this.hasAsthma,
    required this.hasHeartFailure,
    required this.hasMobilityIssues,
    required this.hasCancer,
    required this.otherDiseases,
  });

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'blood_group': bloodGroup,
      'weight': weight,
      'disabilities': disabilities,
      'is_pregnant': isPregnant,
      'has_diabetes': hasDiabetes,
      'has_asthma': hasAsthma,
      'has_heart_failure': hasHeartFailure,
      'has_mobility_issues': hasMobilityIssues,
      'has_cancer': hasCancer,
      'other_diseases': otherDiseases,
    };
  }

  factory MedicalData.fromJson(Map<String, dynamic> json) {
    return MedicalData(
      gender: json['gender'] ?? 'male',
      bloodGroup: json['blood_group'] ?? 'not_selected',
      weight: (json['weight'] ?? 0).toDouble(),
      disabilities: List<String>.from(json['disabilities'] ?? []),
      isPregnant: json['is_pregnant'] ?? false,
      hasDiabetes: json['has_diabetes'] ?? false,
      hasAsthma: json['has_asthma'] ?? false,
      hasHeartFailure: json['has_heart_failure'] ?? false,
      hasMobilityIssues: json['has_mobility_issues'] ?? false,
      hasCancer: json['has_cancer'] ?? false,
      otherDiseases: json['other_diseases'] ?? '',
    );
  }

  factory MedicalData.empty() {
    return MedicalData(
      gender: 'male',
      bloodGroup: 'not_selected',
      weight: 0,
      disabilities: [],
      isPregnant: false,
      hasDiabetes: false,
      hasAsthma: false,
      hasHeartFailure: false,
      hasMobilityIssues: false,
      hasCancer: false,
      otherDiseases: '',
    );
  }
  
  MedicalData copyWith({
    String? gender,
    String? bloodGroup,
    double? weight,
    List<String>? disabilities,
    bool? isPregnant,
    bool? hasDiabetes,
    bool? hasAsthma,
    bool? hasHeartFailure,
    bool? hasMobilityIssues,
    bool? hasCancer,
    String? otherDiseases,
  }) {
    return MedicalData(
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      weight: weight ?? this.weight,
      disabilities: disabilities ?? this.disabilities,
      isPregnant: isPregnant ?? this.isPregnant,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      hasAsthma: hasAsthma ?? this.hasAsthma,
      hasHeartFailure: hasHeartFailure ?? this.hasHeartFailure,
      hasMobilityIssues: hasMobilityIssues ?? this.hasMobilityIssues,
      hasCancer: hasCancer ?? this.hasCancer,
      otherDiseases: otherDiseases ?? this.otherDiseases,
    );
  }
}
