import 'dart:math';
import '../models/specimen_model.dart';

class RockDatabaseService {
  static final RockDatabaseService _instance = RockDatabaseService._internal();
  factory RockDatabaseService() => _instance;
  static RockDatabaseService get instance => _instance;
  RockDatabaseService._internal();
  
  // In-memory collection storage for demo purposes
  final List<SpecimenModel> _userCollection = [];

  static const List<Map<String, dynamic>> _rockDatabase = [
    // Igneous Rocks - Intrusive
    {
      "id": 101,
      "name": "Granite",
      "category": "Igneous",
      "subcategory": "Intrusive",
      "description": "Coarse-grained plutonic rock composed mainly of quartz, feldspar, and mica. Forms deep underground through slow cooling of magma.",
      "mineralogy": ["Quartz", "K-feldspar", "Plagioclase", "Biotite", "Muscovite"],
      "physicalProperties": {
        "hardness": "6-7 Mohs",
        "density": "2.6-2.7 g/cm³",
        "porosity": "0.5-1.5%",
        "color": "Light gray to pink"
      },
      "formation": "Deep crustal intrusions, batholiths",
      "uses": ["Construction", "Countertops", "Monuments"],
      "locations": ["Sierra Nevada", "Canadian Shield", "Appalachians"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 102,
      "name": "Gabbro",
      "category": "Igneous",
      "subcategory": "Intrusive",
      "description": "Dark, coarse-grained intrusive rock composed mainly of plagioclase and pyroxene. Oceanic crustal equivalent.",
      "mineralogy": ["Plagioclase", "Pyroxene", "Olivine", "Magnetite"],
      "physicalProperties": {
        "hardness": "6-7 Mohs",
        "density": "2.85-3.05 g/cm³",
        "porosity": "0.2-1%",
        "color": "Dark gray to black"
      },
      "formation": "Oceanic crust, layered intrusions",
      "uses": ["Aggregate", "Dimension stone", "Countertops"],
      "locations": ["Mid-ocean ridges", "Layered intrusions", "Ophiolites"],
      "imageUrl": "https://images.pexels.com/photos/1029641/pexels-photo-1029641.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 103,
      "name": "Diorite",
      "category": "Igneous",
      "subcategory": "Intrusive",
      "description": "Intermediate composition intrusive rock, darker than granite but lighter than gabbro.",
      "mineralogy": ["Plagioclase", "Hornblende", "Biotite", "Pyroxene"],
      "physicalProperties": {
        "hardness": "6-7 Mohs",
        "density": "2.7-2.9 g/cm³",
        "porosity": "0.5-2%",
        "color": "Gray to dark gray"
      },
      "formation": "Continental arc magmatism",
      "uses": ["Construction", "Road aggregate", "Decorative stone"],
      "locations": ["Andes", "Sierra Nevada", "European Alps"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    
    // Igneous Rocks - Extrusive
    {
      "id": 104,
      "name": "Basalt",
      "category": "Igneous",
      "subcategory": "Extrusive",
      "description": "Fine-grained volcanic rock, most common volcanic rock on Earth. Forms oceanic crust.",
      "mineralogy": ["Plagioclase", "Pyroxene", "Olivine", "Magnetite"],
      "physicalProperties": {
        "hardness": "6 Mohs",
        "density": "2.9-3.1 g/cm³",
        "porosity": "1-10%",
        "color": "Dark gray to black"
      },
      "formation": "Volcanic eruptions, oceanic spreading",
      "uses": ["Aggregate", "Railroad ballast", "Fiber insulation"],
      "locations": ["Mid-ocean ridges", "Volcanic islands", "Continental flood basalts"],
      "imageUrl": "https://images.pexels.com/photos/1029641/pexels-photo-1029641.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 105,
      "name": "Andesite",
      "category": "Igneous",
      "subcategory": "Extrusive",
      "description": "Intermediate volcanic rock common in subduction zones and volcanic arcs.",
      "mineralogy": ["Plagioclase", "Hornblende", "Pyroxene", "Biotite"],
      "physicalProperties": {
        "hardness": "5-6 Mohs",
        "density": "2.5-2.8 g/cm³",
        "porosity": "2-15%",
        "color": "Gray to dark gray"
      },
      "formation": "Stratovolcanoes, volcanic arcs",
      "uses": ["Aggregate", "Dimension stone", "Road construction"],
      "locations": ["Andes Mountains", "Pacific Ring of Fire", "Cascade Range"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 106,
      "name": "Rhyolite",
      "category": "Igneous",
      "subcategory": "Extrusive",
      "description": "Felsic volcanic rock with high silica content. Often contains glass and phenocrysts.",
      "mineralogy": ["Quartz", "K-feldspar", "Plagioclase", "Biotite"],
      "physicalProperties": {
        "hardness": "6-7 Mohs",
        "density": "2.3-2.6 g/cm³",
        "porosity": "5-20%",
        "color": "Light gray to pink"
      },
      "formation": "Explosive volcanic eruptions",
      "uses": ["Aggregate", "Decorative stone", "Abrasives"],
      "locations": ["Yellowstone", "Nevada", "New Zealand"],
      "imageUrl": "https://images.pexels.com/photos/1029641/pexels-photo-1029641.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    
    // Sedimentary Rocks - Clastic
    {
      "id": 201,
      "name": "Sandstone",
      "category": "Sedimentary",
      "subcategory": "Clastic",
      "description": "Medium-grained clastic rock composed mainly of sand-sized minerals and rock fragments.",
      "mineralogy": ["Quartz", "Feldspar", "Rock fragments", "Clay minerals"],
      "physicalProperties": {
        "hardness": "6-7 Mohs",
        "density": "2.0-2.6 g/cm³",
        "porosity": "5-25%",
        "color": "Tan, brown, red, gray"
      },
      "formation": "Desert, beach, and river environments",
      "uses": ["Construction", "Glass making", "Foundry sand"],
      "locations": ["Colorado Plateau", "Appalachians", "Great Plains"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 202,
      "name": "Shale",
      "category": "Sedimentary",
      "subcategory": "Clastic",
      "description": "Fine-grained sedimentary rock formed from compressed mud and clay particles.",
      "mineralogy": ["Clay minerals", "Quartz", "Mica", "Organic matter"],
      "physicalProperties": {
        "hardness": "1-2 Mohs",
        "density": "2.1-2.7 g/cm³",
        "porosity": "5-45%",
        "color": "Gray, black, brown, red"
      },
      "formation": "Deep water marine, lacustrine environments",
      "uses": ["Brick making", "Oil and gas source rock", "Pottery"],
      "locations": ["Appalachian Basin", "Permian Basin", "Bakken Formation"],
      "imageUrl": "https://images.pexels.com/photos/1029641/pexels-photo-1029641.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 203,
      "name": "Conglomerate",
      "category": "Sedimentary",
      "subcategory": "Clastic",
      "description": "Coarse-grained sedimentary rock with rounded clasts larger than 2mm in a finer matrix.",
      "mineralogy": ["Various rock fragments", "Quartz", "Feldspar", "Matrix minerals"],
      "physicalProperties": {
        "hardness": "Variable",
        "density": "2.3-2.8 g/cm³",
        "porosity": "5-20%",
        "color": "Variable, often colorful"
      },
      "formation": "Alluvial fans, river channels",
      "uses": ["Aggregate", "Decorative stone", "Concrete"],
      "locations": ["Basin and Range", "Rocky Mountains", "Appalachians"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    
    // Sedimentary Rocks - Chemical
    {
      "id": 204,
      "name": "Limestone",
      "category": "Sedimentary",
      "subcategory": "Chemical",
      "description": "Carbonate rock composed primarily of calcium carbonate, often containing fossils.",
      "mineralogy": ["Calcite", "Aragonite", "Dolomite", "Fossils"],
      "physicalProperties": {
        "hardness": "3 Mohs",
        "density": "2.3-2.7 g/cm³",
        "porosity": "1-30%",
        "color": "White, gray, cream, blue"
      },
      "formation": "Marine environments, coral reefs",
      "uses": ["Cement", "Aggregate", "Dimension stone"],
      "locations": ["Florida", "Yucatan", "Alps", "Great Barrier Reef"],
      "imageUrl": "https://images.pexels.com/photos/1029641/pexels-photo-1029641.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 205,
      "name": "Dolostone",
      "category": "Sedimentary",
      "subcategory": "Chemical",
      "description": "Carbonate rock composed primarily of the mineral dolomite.",
      "mineralogy": ["Dolomite", "Calcite", "Quartz", "Clay minerals"],
      "physicalProperties": {
        "hardness": "3.5-4 Mohs",
        "density": "2.8-2.9 g/cm³",
        "porosity": "1-25%",
        "color": "White, gray, pink"
      },
      "formation": "Marine evaporation, limestone alteration",
      "uses": ["Steel making", "Glass making", "Aggregate"],
      "locations": ["Niagara Escarpment", "Permian Basin", "Dolomites"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    
    // Metamorphic Rocks - Foliated
    {
      "id": 301,
      "name": "Gneiss",
      "category": "Metamorphic",
      "subcategory": "Foliated",
      "description": "High-grade metamorphic rock with distinctive banded texture of light and dark minerals.",
      "mineralogy": ["Quartz", "Feldspar", "Mica", "Hornblende"],
      "physicalProperties": {
        "hardness": "6-7 Mohs",
        "density": "2.6-3.0 g/cm³",
        "porosity": "0.5-2%",
        "color": "Banded light and dark"
      },
      "formation": "High-grade regional metamorphism",
      "uses": ["Construction", "Decorative stone", "Aggregate"],
      "locations": ["Canadian Shield", "Appalachians", "Scandinavian Shield"],
      "imageUrl": "https://images.pexels.com/photos/1029641/pexels-photo-1029641.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 302,
      "name": "Schist",
      "category": "Metamorphic",
      "subcategory": "Foliated",
      "description": "Medium to high-grade metamorphic rock with prominent schistose foliation.",
      "mineralogy": ["Mica", "Quartz", "Feldspar", "Garnet", "Staurolite"],
      "physicalProperties": {
        "hardness": "4-6 Mohs",
        "density": "2.6-2.9 g/cm³",
        "porosity": "1-5%",
        "color": "Gray, brown, green, red"
      },
      "formation": "Regional metamorphism of shale or slate",
      "uses": ["Roofing", "Decorative stone", "Aggregate"],
      "locations": ["Scottish Highlands", "Vermont", "Swiss Alps"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 303,
      "name": "Slate",
      "category": "Metamorphic",
      "subcategory": "Foliated",
      "description": "Low-grade metamorphic rock that splits easily along parallel planes.",
      "mineralogy": ["Clay minerals", "Mica", "Quartz", "Chlorite"],
      "physicalProperties": {
        "hardness": "3-5 Mohs",
        "density": "2.7-2.8 g/cm³",
        "porosity": "0.1-1%",
        "color": "Gray, black, green, purple"
      },
      "formation": "Low-grade metamorphism of shale",
      "uses": ["Roofing", "Flooring", "Billiard tables"],
      "locations": ["Wales", "Vermont", "Ardennes"],
      "imageUrl": "https://images.pexels.com/photos/1029641/pexels-photo-1029641.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    
    // Metamorphic Rocks - Non-foliated
    {
      "id": 304,
      "name": "Marble",
      "category": "Metamorphic",
      "subcategory": "Non-foliated",
      "description": "Metamorphosed limestone or dolostone with interlocking calcite or dolomite crystals.",
      "mineralogy": ["Calcite", "Dolomite", "Quartz", "Mica", "Graphite"],
      "physicalProperties": {
        "hardness": "3-5 Mohs",
        "density": "2.5-2.8 g/cm³",
        "porosity": "0.1-2%",
        "color": "White, gray, various colors"
      },
      "formation": "Contact or regional metamorphism of limestone",
      "uses": ["Sculpture", "Building stone", "Countertops"],
      "locations": ["Carrara Italy", "Pentelic Greece", "Vermont"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 305,
      "name": "Quartzite",
      "category": "Metamorphic",
      "subcategory": "Non-foliated",
      "description": "Hard, non-foliated metamorphic rock formed from quartz-rich sandstone.",
      "mineralogy": ["Quartz", "Minor feldspar", "Mica", "Iron oxides"],
      "physicalProperties": {
        "hardness": "7 Mohs",
        "density": "2.6-2.8 g/cm³",
        "porosity": "0.1-3%",
        "color": "White, gray, pink, red"
      },
      "formation": "Metamorphism of pure quartz sandstone",
      "uses": ["Aggregate", "Dimension stone", "Abrasives"],
      "locations": ["Appalachians", "Canadian Shield", "Quartzite Ridge"],
      "imageUrl": "https://images.pexels.com/photos/1029641/pexels-photo-1029641.jpeg?auto=compress&cs=tinysrgb&w=800"
    },

    // Ocean-specific specimens
    {
      "id": 401,
      "name": "Pillow Basalt",
      "category": "Igneous",
      "subcategory": "Submarine Volcanic",
      "description": "Basaltic lava erupted underwater, forming characteristic pillow-shaped structures.",
      "mineralogy": ["Plagioclase", "Pyroxene", "Olivine", "Glass rim"],
      "physicalProperties": {
        "hardness": "5-6 Mohs",
        "density": "2.8-3.0 g/cm³",
        "porosity": "5-15%",
        "color": "Dark gray to black with glassy rim"
      },
      "formation": "Underwater volcanic eruptions at mid-ocean ridges",
      "uses": ["Geological research", "Aggregate", "Educational samples"],
      "locations": ["Mid-ocean ridges", "Ophiolite complexes", "Ocean floor"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 402,
      "name": "Manganese Nodule",
      "category": "Sedimentary",
      "subcategory": "Marine Chemical",
      "description": "Polymetallic concretions formed on abyssal ocean floors over millions of years.",
      "mineralogy": ["Manganese oxides", "Iron oxides", "Nickel", "Copper", "Cobalt"],
      "physicalProperties": {
        "hardness": "2-4 Mohs",
        "density": "2.0-3.5 g/cm³",
        "porosity": "30-60%",
        "color": "Dark brown to black"
      },
      "formation": "Slow precipitation from seawater on abyssal plains",
      "uses": ["Potential ore source", "Research", "Industrial applications"],
      "locations": ["Clarion-Clipperton Zone", "Peru Basin", "Central Indian Ocean"],
      "imageUrl": "https://images.pexels.com/photos/1029641/pexels-photo-1029641.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 403,
      "name": "Serpentinite",
      "category": "Metamorphic",
      "subcategory": "Hydrothermal",
      "description": "Rock composed mainly of serpentine minerals, formed by hydration of ultramafic rocks.",
      "mineralogy": ["Serpentine", "Magnetite", "Chromite", "Brucite"],
      "physicalProperties": {
        "hardness": "2-5 Mohs",
        "density": "2.5-2.6 g/cm³",
        "porosity": "1-10%",
        "color": "Green, yellow-green, black"
      },
      "formation": "Hydration of peridotite at mid-ocean ridges",
      "uses": ["Decorative stone", "Asbestos source", "Research"],
      "locations": ["Ophiolites", "Mid-ocean ridges", "Subduction zones"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 404,
      "name": "Hydrothermal Sulfides",
      "category": "Igneous",
      "subcategory": "Hydrothermal",
      "description": "Metallic sulfide minerals precipitated from hydrothermal vent fluids.",
      "mineralogy": ["Pyrite", "Chalcopyrite", "Sphalerite", "Galena", "Pyrrhotite"],
      "physicalProperties": {
        "hardness": "1-6 Mohs",
        "density": "3.5-7.5 g/cm³",
        "porosity": "5-40%",
        "color": "Metallic gold, bronze, silver"
      },
      "formation": "Precipitation from high-temperature hydrothermal fluids",
      "uses": ["Ore deposits", "Research", "Industrial applications"],
      "locations": ["Mid-ocean ridges", "Black smoker vents", "Kuroko deposits"],
      "imageUrl": "https://images.pexels.com/photos/1029641/pexels-photo-1029641.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 405,
      "name": "Pelagic Sediment",
      "category": "Sedimentary",
      "subcategory": "Marine Biological",
      "description": "Fine-grained deep-sea sediment composed of marine organism remains and clay.",
      "mineralogy": ["Calcium carbonate", "Silica", "Clay minerals", "Organic matter"],
      "physicalProperties": {
        "hardness": "1-3 Mohs",
        "density": "1.2-2.5 g/cm³",
        "porosity": "50-90%",
        "color": "White, cream, brown, red"
      },
      "formation": "Slow accumulation on abyssal ocean floor",
      "uses": ["Paleoclimate research", "Industrial applications", "Filtration"],
      "locations": ["Deep ocean basins", "Abyssal plains", "Mid-ocean ridges"],
      "imageUrl": "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800"
    }
  ];

  // Collection management methods
  Future<List<SpecimenModel>> getAllSpecimens() async {
    // Convert database specimens to SpecimenModel instances
    final specimens = <SpecimenModel>[];
    for (final data in _rockDatabase) {
      try {
        specimens.add(_createSpecimenModel(data));
      } catch (e) {
        // Skip invalid specimens
        continue;
      }
    }
    return specimens;
  }
  
  Future<List<SpecimenModel>> getUserCollection() async {
    return List<SpecimenModel>.from(_userCollection);
  }
  
  Future<void> addToCollection(SpecimenModel specimen) async {
    _userCollection.add(specimen);
  }
  
  Future<void> removeFromCollection(String specimenId) async {
    _userCollection.removeWhere((s) => s.id.toString() == specimenId);
  }
  
  Future<void> updateSpecimenInCollection(SpecimenModel specimen) async {
    final index = _userCollection.indexWhere((s) => s.id == specimen.id);
    if (index != -1) {
      _userCollection[index] = specimen;
    }
  }
  
  Future<void> clearCollection() async {
    _userCollection.clear();
  }
  
  SpecimenModel _createSpecimenModel(Map<String, dynamic> data) {
    final physicalProps = data['physicalProperties'] as Map<String, dynamic>;
    
    return SpecimenModel(
      id: data['id'] as int,
      name: data['name'] as String,
      confidence: 85.0, // Default confidence for database specimens
      location: (data['locations'] as List).isNotEmpty 
          ? (data['locations'] as List).first.toString()
          : 'Unknown',
      date: DateTime.now().toString().substring(0, 10),
      status: 'confirmed',
      imageUrl: data['imageUrl'] as String,
      geologicalPeriod: 'Recent',
      formation: data['formation'] as String,
      isFavorite: false,
      category: data['category'] as String,
      subcategory: data['subcategory'] as String,
      description: data['description'] as String,
      mineralogy: List<String>.from(data['mineralogy'] as List),
      physicalProperties: PhysicalProperties.fromMap(physicalProps),
      uses: List<String>.from(data['uses'] as List),
      scientificName: data['name'] as String,
      commonName: data['name'] as String,
      dateAdded: DateTime.now(),
    );
  }

  List<Map<String, dynamic>> getAllSpecimensAsMap() {
    return List.from(_rockDatabase);
  }

  List<Map<String, dynamic>> getSpecimensByCategory(String category) {
    return _rockDatabase
        .where((specimen) => specimen['category'].toString().toLowerCase() == category.toLowerCase())
        .toList();
  }

  List<Map<String, dynamic>> searchSpecimens(String query) {
    final lowerQuery = query.toLowerCase();
    return _rockDatabase.where((specimen) {
      return specimen['name'].toString().toLowerCase().contains(lowerQuery) ||
          specimen['category'].toString().toLowerCase().contains(lowerQuery) ||
          specimen['subcategory'].toString().toLowerCase().contains(lowerQuery) ||
          specimen['description'].toString().toLowerCase().contains(lowerQuery) ||
          (specimen['mineralogy'] as List).any((mineral) => 
              mineral.toString().toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Map<String, dynamic>? getSpecimenById(int id) {
    try {
      return _rockDatabase.firstWhere((specimen) => specimen['id'] == id);
    } catch (e) {
      return null;
    }
  }

  List<String> getCategories() {
    return _rockDatabase
        .map((specimen) => specimen['category'].toString())
        .toSet()
        .toList()
        ..sort();
  }

  List<String> getSubcategories(String category) {
    return _rockDatabase
        .where((specimen) => specimen['category'].toString() == category)
        .map((specimen) => specimen['subcategory'].toString())
        .toSet()
        .toList()
        ..sort();
  }

  List<String> getAllMinerals() {
    final minerals = <String>{};
    for (final specimen in _rockDatabase) {
      final specimenMinerals = specimen['mineralogy'] as List;
      minerals.addAll(specimenMinerals.cast<String>());
    }
    return minerals.toList()..sort();
  }

  // Generate realistic specimen data for collection
  List<Map<String, dynamic>> generateCollectionSpecimens(int count) {
    final random = Random();
    final List<Map<String, dynamic>> specimens = [];
    
    final locations = [
      "Mid-Atlantic Ridge, 42°N 28°W",
      "Clarion-Clipperton Zone, Pacific",
      "Lost City Hydrothermal Field",
      "East Pacific Rise, 21°N",
      "Champagne Vent Field",
      "Juan de Fuca Ridge",
      "Gakkel Ridge, Arctic Ocean",
      "Mendocino Seamount",
      "TAG Hydrothermal Field",
      "Lucky Strike Vent Field",
      "Rainbow Hydrothermal Field",
      "Logatchev Vent Field",
      "Turtle Pits Vent Field",
      "Endeavour Segment",
      "Guaymas Basin"
    ];
    
    final statuses = ["confirmed", "probable", "uncertain"];
    
    for (int i = 0; i < count; i++) {
      final baseSpecimen = _rockDatabase[random.nextInt(_rockDatabase.length)];
      final location = locations[random.nextInt(locations.length)];
      final date = _generateRandomDate();
      final confidence = 60.0 + random.nextDouble() * 35; // 60-95% confidence
      final status = statuses[random.nextInt(statuses.length)];
      
      specimens.add({
        "id": 1000 + i,
        "name": baseSpecimen['name'],
        "confidence": double.parse(confidence.toStringAsFixed(1)),
        "location": location,
        "date": date,
        "status": status,
        "imageUrl": baseSpecimen['imageUrl'],
        "geologicalPeriod": _getRandomGeologicalPeriod(),
        "formation": _getFormationForLocation(location),
        "isFavorite": random.nextBool(),
        "category": baseSpecimen['category'],
        "subcategory": baseSpecimen['subcategory'],
        "description": baseSpecimen['description'],
        "mineralogy": baseSpecimen['mineralogy'],
        "physicalProperties": baseSpecimen['physicalProperties'],
        "uses": baseSpecimen['uses']
      });
    }
    
    return specimens;
  }

  String _generateRandomDate() {
    final random = Random();
    final now = DateTime.now();
    final daysAgo = random.nextInt(30); // Last 30 days
    final date = now.subtract(Duration(days: daysAgo));
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  String _getRandomGeologicalPeriod() {
    final periods = ["Recent", "Quaternary", "Cenozoic", "Mesozoic", "Paleozoic", "Precambrian"];
    final random = Random();
    return periods[random.nextInt(periods.length)];
  }

  String _getFormationForLocation(String location) {
    if (location.contains("Ridge") || location.contains("Rise")) {
      return "Mid-Ocean Ridge";
    } else if (location.contains("Vent") || location.contains("Hydrothermal")) {
      return "Hydrothermal Deposit";
    } else if (location.contains("Seamount")) {
      return "Seamount";
    } else if (location.contains("Basin")) {
      return "Abyssal Plain";
    } else {
      return "Oceanic Crust";
    }
  }

  // Simulate AI identification results
  Map<String, dynamic> identifySpecimen(String imagePath) {
    final random = Random();
    final specimen = _rockDatabase[random.nextInt(_rockDatabase.length)];
    final confidence = 70.0 + random.nextDouble() * 25; // 70-95% confidence
    
    return {
      "specimen": specimen,
      "confidence": double.parse(confidence.toStringAsFixed(1)),
      "alternatives": _getAlternativeIdentifications(specimen, 3),
      "timestamp": DateTime.now().toIso8601String(),
    };
  }

  List<Map<String, dynamic>> _getAlternativeIdentifications(Map<String, dynamic> primary, int count) {
    final random = Random();
    final alternatives = <Map<String, dynamic>>[];
    final category = primary['category'];
    
    // Get specimens from same category for realistic alternatives
    final sameCategory = _rockDatabase
        .where((s) => s['category'] == category && s['id'] != primary['id'])
        .toList();
    
    for (int i = 0; i < count && i < sameCategory.length; i++) {
      final alt = sameCategory[random.nextInt(sameCategory.length)];
      final confidence = 20.0 + random.nextDouble() * 40; // 20-60% confidence
      
      alternatives.add({
        "specimen": alt,
        "confidence": double.parse(confidence.toStringAsFixed(1)),
      });
      
      sameCategory.remove(alt); // Avoid duplicates
    }
    
    return alternatives;
  }
}