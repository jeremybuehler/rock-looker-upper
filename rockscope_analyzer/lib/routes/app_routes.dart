import 'package:flutter/material.dart';
import '../presentation/collection_manager/collection_manager.dart';
import '../presentation/symbol_detail_view/symbol_detail_view.dart';
import '../presentation/field_notes/field_notes.dart';
import '../presentation/database_browser/database_browser.dart';
import '../presentation/specimen_identification/specimen_identification.dart';
import '../presentation/camera_capture/camera_capture.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String collectionManager = '/collection-manager';
  static const String symbolDetailView = '/symbol-detail-view';
  static const String fieldNotes = '/field-notes';
  static const String databaseBrowser = '/database-browser';
  static const String specimenIdentification = '/specimen-identification';
  static const String cameraCapture = '/camera-capture';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const CollectionManager(),
    collectionManager: (context) => const CollectionManager(),
    symbolDetailView: (context) => const SymbolDetailView(),
    fieldNotes: (context) => const FieldNotes(),
    databaseBrowser: (context) => const DatabaseBrowser(),
    specimenIdentification: (context) => const SpecimenIdentification(),
    cameraCapture: (context) => const CameraCapture(),
    // TODO: Add your other routes here
  };
}
