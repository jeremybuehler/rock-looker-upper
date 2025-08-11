class SpecimenModel {
  final int id;
  final String name;
  final double confidence;
  final String location;
  final String date;
  final String status;
  final String imageUrl;
  final String geologicalPeriod;
  final String formation;
  final bool isFavorite;
  final String category;
  final String subcategory;
  final String description;
  final List<String> mineralogy;
  final PhysicalProperties physicalProperties;
  final List<String> uses;
  
  // Additional properties needed by providers
  final String scientificName;
  final String commonName;
  final DateTime? dateAdded;

  SpecimenModel({
    required this.id,
    required this.name,
    required this.confidence,
    required this.location,
    required this.date,
    required this.status,
    required this.imageUrl,
    required this.geologicalPeriod,
    required this.formation,
    required this.isFavorite,
    required this.category,
    required this.subcategory,
    required this.description,
    required this.mineralogy,
    required this.physicalProperties,
    required this.uses,
    required this.scientificName,
    required this.commonName,
    this.dateAdded,
  });

  factory SpecimenModel.fromMap(Map<String, dynamic> map) {
    final physicalProps = map['physicalProperties'] as Map<String, dynamic>;
    
    return SpecimenModel(
      id: map['id'] as int,
      name: map['name'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      location: map['location'] as String,
      date: map['date'] as String,
      status: map['status'] as String,
      imageUrl: map['imageUrl'] as String,
      geologicalPeriod: map['geologicalPeriod'] as String,
      formation: map['formation'] as String,
      isFavorite: map['isFavorite'] as bool,
      category: map['category'] as String,
      subcategory: map['subcategory'] as String,
      description: map['description'] as String,
      mineralogy: List<String>.from(map['mineralogy'] as List),
      physicalProperties: PhysicalProperties.fromMap(physicalProps),
      uses: List<String>.from(map['uses'] as List),
      scientificName: map['scientificName'] as String? ?? map['name'] as String,
      commonName: map['commonName'] as String? ?? map['name'] as String,
      dateAdded: map['dateAdded'] != null ? DateTime.parse(map['dateAdded'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'confidence': confidence,
      'location': location,
      'date': date,
      'status': status,
      'imageUrl': imageUrl,
      'geologicalPeriod': geologicalPeriod,
      'formation': formation,
      'isFavorite': isFavorite,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'mineralogy': mineralogy,
      'physicalProperties': physicalProperties.toMap(),
      'uses': uses,
      'scientificName': scientificName,
      'commonName': commonName,
      'dateAdded': dateAdded?.toIso8601String(),
    };
  }

  SpecimenModel copyWith({
    int? id,
    String? name,
    double? confidence,
    String? location,
    String? date,
    String? status,
    String? imageUrl,
    String? geologicalPeriod,
    String? formation,
    bool? isFavorite,
    String? category,
    String? subcategory,
    String? description,
    List<String>? mineralogy,
    PhysicalProperties? physicalProperties,
    List<String>? uses,
    String? scientificName,
    String? commonName,
    DateTime? dateAdded,
  }) {
    return SpecimenModel(
      id: id ?? this.id,
      name: name ?? this.name,
      confidence: confidence ?? this.confidence,
      location: location ?? this.location,
      date: date ?? this.date,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      geologicalPeriod: geologicalPeriod ?? this.geologicalPeriod,
      formation: formation ?? this.formation,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      mineralogy: mineralogy ?? this.mineralogy,
      physicalProperties: physicalProperties ?? this.physicalProperties,
      uses: uses ?? this.uses,
      scientificName: scientificName ?? this.scientificName,
      commonName: commonName ?? this.commonName,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  String toString() {
    return 'SpecimenModel(id: $id, name: $name, confidence: $confidence, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SpecimenModel &&
      other.id == id &&
      other.name == name &&
      other.confidence == confidence &&
      other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      confidence.hashCode ^
      status.hashCode;
  }
}

class PhysicalProperties {
  final String hardness;
  final String density;
  final String porosity;
  final String color;

  PhysicalProperties({
    required this.hardness,
    required this.density,
    required this.porosity,
    required this.color,
  });

  factory PhysicalProperties.fromMap(Map<String, dynamic> map) {
    return PhysicalProperties(
      hardness: map['hardness'] as String,
      density: map['density'] as String,
      porosity: map['porosity'] as String,
      color: map['color'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hardness': hardness,
      'density': density,
      'porosity': porosity,
      'color': color,
    };
  }

  PhysicalProperties copyWith({
    String? hardness,
    String? density,
    String? porosity,
    String? color,
  }) {
    return PhysicalProperties(
      hardness: hardness ?? this.hardness,
      density: density ?? this.density,
      porosity: porosity ?? this.porosity,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'PhysicalProperties(hardness: $hardness, density: $density, porosity: $porosity, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PhysicalProperties &&
      other.hardness == hardness &&
      other.density == density &&
      other.porosity == porosity &&
      other.color == color;
  }

  @override
  int get hashCode {
    return hardness.hashCode ^
      density.hashCode ^
      porosity.hashCode ^
      color.hashCode;
  }
}

class IdentificationResult {
  final SpecimenModel specimen;
  final double confidence;
  final List<AlternativeIdentification> alternatives;
  final String timestamp;

  IdentificationResult({
    required this.specimen,
    required this.confidence,
    required this.alternatives,
    required this.timestamp,
  });

  factory IdentificationResult.fromMap(Map<String, dynamic> map) {
    return IdentificationResult(
      specimen: SpecimenModel.fromMap(map['specimen'] as Map<String, dynamic>),
      confidence: (map['confidence'] as num).toDouble(),
      alternatives: List<AlternativeIdentification>.from(
        (map['alternatives'] as List).map((x) => AlternativeIdentification.fromMap(x as Map<String, dynamic>))
      ),
      timestamp: map['timestamp'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'specimen': specimen.toMap(),
      'confidence': confidence,
      'alternatives': alternatives.map((x) => x.toMap()).toList(),
      'timestamp': timestamp,
    };
  }
}

class AlternativeIdentification {
  final SpecimenModel specimen;
  final double confidence;

  AlternativeIdentification({
    required this.specimen,
    required this.confidence,
  });

  factory AlternativeIdentification.fromMap(Map<String, dynamic> map) {
    return AlternativeIdentification(
      specimen: SpecimenModel.fromMap(map['specimen'] as Map<String, dynamic>),
      confidence: (map['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'specimen': specimen.toMap(),
      'confidence': confidence,
    };
  }
}