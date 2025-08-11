import 'dart:convert';
import 'dart:math';

class FieldNotesService {
  static final FieldNotesService _instance = FieldNotesService._internal();
  factory FieldNotesService() => _instance;
  static FieldNotesService get instance => _instance;
  FieldNotesService._internal();

  final List<Map<String, dynamic>> _fieldNotes = [];
  final List<Map<String, dynamic>> _mockFieldNotes = [
    {
      "id": 1,
      "title": "Hydrothermal Vent Field Survey",
      "date": "Aug 8, 2025",
      "location": "Lost City Hydrothermal Field",
      "coordinates": "30°07'N, 42°07'W",
      "weather": "Calm seas, clear visibility",
      "depth": "750m",
      "temperature": "4°C",
      "notes": "Discovered active carbonate chimneys with unique mineral formations. Strong sulfur smell indicates active hydrothermal activity. Multiple specimen collection points identified.",
      "specimens": [1, 3, 5],
      "images": 8,
      "tags": ["hydrothermal", "active", "carbonate"],
      "priority": "high"
    },
    {
      "id": 2,
      "title": "Mid-Ocean Ridge Basalt Collection",
      "date": "Aug 7, 2025", 
      "location": "Mid-Atlantic Ridge",
      "coordinates": "42°12'N, 28°15'W",
      "weather": "Moderate seas, good visibility",
      "depth": "2,100m",
      "temperature": "2°C",
      "notes": "Fresh pillow basalt formations observed along ridge axis. Glass rims well-preserved. Evidence of recent volcanic activity with minimal sediment cover.",
      "specimens": [2, 4, 6],
      "images": 12,
      "tags": ["basalt", "volcanic", "fresh"],
      "priority": "medium"
    },
    {
      "id": 3,
      "title": "Abyssal Plain Sediment Analysis",
      "date": "Aug 6, 2025",
      "location": "Clarion-Clipperton Zone",
      "coordinates": "12°N, 120°W", 
      "weather": "Rough seas, limited visibility",
      "depth": "4,200m",
      "temperature": "1.5°C",
      "notes": "Extensive manganese nodule field discovered. Nodules show varying sizes and compositions. Potential commercial significance requires further analysis.",
      "specimens": [7, 8],
      "images": 15,
      "tags": ["manganese", "nodules", "commercial"],
      "priority": "high"
    },
    {
      "id": 4,
      "title": "Seamount Exploration",
      "date": "Aug 5, 2025",
      "location": "Mendocino Seamount",
      "coordinates": "39°55'N, 126°40'W",
      "weather": "Clear conditions, excellent visibility",
      "depth": "1,800m",
      "temperature": "3°C",
      "notes": "Diverse geological features observed. Evidence of polymetallic crust formation on seamount flanks. Biological activity suggests unique ecosystem.",
      "specimens": [9, 10],
      "images": 6,
      "tags": ["seamount", "crust", "ecosystem"],
      "priority": "medium"
    },
    {
      "id": 5,
      "title": "Transform Fault Investigation",
      "date": "Aug 4, 2025",
      "location": "Fracture Zone A",
      "coordinates": "36°N, 33°W",
      "weather": "Calm seas",
      "depth": "3,500m", 
      "temperature": "2°C",
      "notes": "Complex fault structure with exposed mantle rocks. Serpentinization processes active. Unique mineral assemblages formed through tectonic processes.",
      "specimens": [11],
      "images": 9,
      "tags": ["fault", "mantle", "serpentinization"],
      "priority": "low"
    }
  ];

  List<Map<String, dynamic>> getAllFieldNotes() {
    final combined = List<Map<String, dynamic>>.from(_mockFieldNotes);
    combined.addAll(_fieldNotes);
    combined.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    return combined;
  }
  
  // Provider-expected methods
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    return getAllFieldNotes();
  }
  
  Future<void> saveNote(Map<String, dynamic> note) async {
    if (note.containsKey('id')) {
      // Update existing note
      final index = _fieldNotes.indexWhere((n) => n['id'] == note['id']);
      if (index != -1) {
        _fieldNotes[index] = note;
      } else {
        _fieldNotes.add(note);
      }
    } else {
      // Add new note
      note['id'] = _generateNewId();
      note['date'] = _formatDate(DateTime.now());
      _fieldNotes.add(note);
    }
  }
  
  Future<void> deleteNote(int noteId) async {
    _fieldNotes.removeWhere((note) => note['id'] == noteId);
  }
  
  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    return searchFieldNotes(query);
  }

  List<Map<String, dynamic>> searchFieldNotes(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllFieldNotes().where((note) {
      return note['title'].toString().toLowerCase().contains(lowerQuery) ||
          note['location'].toString().toLowerCase().contains(lowerQuery) ||
          note['notes'].toString().toLowerCase().contains(lowerQuery) ||
          (note['tags'] as List).any((tag) => 
              tag.toString().toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<Map<String, dynamic>> getFieldNotesByPriority(String priority) {
    return getAllFieldNotes()
        .where((note) => note['priority'] == priority)
        .toList();
  }

  List<Map<String, dynamic>> getFieldNotesByLocation(String location) {
    return getAllFieldNotes()
        .where((note) => note['location']
            .toString()
            .toLowerCase()
            .contains(location.toLowerCase()))
        .toList();
  }

  Map<String, dynamic>? getFieldNoteById(int id) {
    try {
      return getAllFieldNotes().firstWhere((note) => note['id'] == id);
    } catch (e) {
      return null;
    }
  }

  void addFieldNote(Map<String, dynamic> note) {
    note['id'] = _generateNewId();
    note['date'] = _formatDate(DateTime.now());
    _fieldNotes.add(note);
  }

  void updateFieldNote(int id, Map<String, dynamic> updates) {
    final index = _fieldNotes.indexWhere((note) => note['id'] == id);
    if (index != -1) {
      _fieldNotes[index] = {..._fieldNotes[index], ...updates};
    }
  }

  void deleteFieldNote(int id) {
    _fieldNotes.removeWhere((note) => note['id'] == id);
  }

  List<String> getAllLocations() {
    return getAllFieldNotes()
        .map((note) => note['location'] as String)
        .toSet()
        .toList()
        ..sort();
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (final note in getAllFieldNotes()) {
      final noteTags = note['tags'] as List;
      tags.addAll(noteTags.cast<String>());
    }
    return tags.toList()..sort();
  }

  Map<String, int> getFieldNoteStats() {
    final notes = getAllFieldNotes();
    return {
      'total': notes.length,
      'high_priority': notes.where((n) => n['priority'] == 'high').length,
      'medium_priority': notes.where((n) => n['priority'] == 'medium').length,
      'low_priority': notes.where((n) => n['priority'] == 'low').length,
      'this_week': notes.where((n) => _isThisWeek(n['date'])).length,
    };
  }

  int _generateNewId() {
    final existingIds = getAllFieldNotes().map((note) => note['id'] as int).toList();
    return existingIds.isNotEmpty ? existingIds.reduce((a, b) => a > b ? a : b) + 1 : 1000;
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  bool _isThisWeek(String dateStr) {
    try {
      // Simple check - in a real app you'd parse the date properly
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      return dateStr.contains("Aug") && dateStr.contains("2025");
    } catch (e) {
      return false;
    }
  }

  // Generate template field note
  Map<String, dynamic> generateTemplateNote({
    required String location,
    required String coordinates,
    required String depth,
    String weather = "Clear conditions",
    String temperature = "2°C",
  }) {
    return {
      "title": "Field Survey - $location",
      "location": location,
      "coordinates": coordinates,
      "weather": weather,
      "depth": depth,
      "temperature": temperature,
      "notes": "Geological observations and specimen collection notes...",
      "specimens": <int>[],
      "images": 0,
      "tags": <String>[],
      "priority": "medium"
    };
  }

  String exportFieldNotesToJSON() {
    final exportData = {
      'export_metadata': {
        'application': 'RockScope Analyzer',
        'version': '1.0.0',
        'export_date': DateTime.now().toIso8601String(),
        'total_notes': getAllFieldNotes().length,
      },
      'field_notes': getAllFieldNotes(),
    };
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  String exportFieldNotesToCSV() {
    final notes = getAllFieldNotes();
    final headers = ['ID', 'Title', 'Date', 'Location', 'Depth', 'Priority', 'Images', 'Specimens'];
    final csvRows = <String>[];
    
    csvRows.add(headers.join(','));
    
    for (final note in notes) {
      final row = [
        note['id'].toString(),
        '"${note['title']}"',
        note['date'],
        '"${note['location']}"',
        note['depth'],
        note['priority'],
        note['images'].toString(),
        (note['specimens'] as List).length.toString(),
      ];
      csvRows.add(row.join(','));
    }
    
    return csvRows.join('\n');
  }
}