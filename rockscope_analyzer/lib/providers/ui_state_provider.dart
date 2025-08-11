/// Riverpod providers for UI state management
/// 
/// Provides centralized state management for UI interactions,
/// responsive behavior, and user interface preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/breakpoints.dart';

/// Provider for current navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for current device type
final deviceTypeProvider = StateProvider<DeviceType>((ref) => DeviceType.mobile);

/// Provider for theme mode (light/dark)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Provider for UI preferences
final uiPreferencesProvider = StateNotifierProvider<UiPreferencesNotifier, UiPreferences>((ref) {
  return UiPreferencesNotifier();
});

/// UI preferences model
class UiPreferences {
  const UiPreferences({
    this.showGridView = true,
    this.compactMode = false,
    this.showThumbnails = true,
    this.enableAnimations = true,
    this.enableHapticFeedback = true,
    this.fontSize = FontSize.medium,
    this.cardSize = CardSize.medium,
  });

  final bool showGridView;
  final bool compactMode;
  final bool showThumbnails;
  final bool enableAnimations;
  final bool enableHapticFeedback;
  final FontSize fontSize;
  final CardSize cardSize;

  UiPreferences copyWith({
    bool? showGridView,
    bool? compactMode,
    bool? showThumbnails,
    bool? enableAnimations,
    bool? enableHapticFeedback,
    FontSize? fontSize,
    CardSize? cardSize,
  }) {
    return UiPreferences(
      showGridView: showGridView ?? this.showGridView,
      compactMode: compactMode ?? this.compactMode,
      showThumbnails: showThumbnails ?? this.showThumbnails,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      fontSize: fontSize ?? this.fontSize,
      cardSize: cardSize ?? this.cardSize,
    );
  }
}

enum FontSize {
  small('Small'),
  medium('Medium'),
  large('Large');

  const FontSize(this.displayName);
  final String displayName;
}

enum CardSize {
  small('Small'),
  medium('Medium'),
  large('Large');

  const CardSize(this.displayName);
  final String displayName;
}

/// State notifier for UI preferences
class UiPreferencesNotifier extends StateNotifier<UiPreferences> {
  UiPreferencesNotifier() : super(const UiPreferences());

  void toggleGridView() {
    state = state.copyWith(showGridView: !state.showGridView);
  }

  void toggleCompactMode() {
    state = state.copyWith(compactMode: !state.compactMode);
  }

  void toggleThumbnails() {
    state = state.copyWith(showThumbnails: !state.showThumbnails);
  }

  void toggleAnimations() {
    state = state.copyWith(enableAnimations: !state.enableAnimations);
  }

  void toggleHapticFeedback() {
    state = state.copyWith(enableHapticFeedback: !state.enableHapticFeedback);
  }

  void setFontSize(FontSize fontSize) {
    state = state.copyWith(fontSize: fontSize);
  }

  void setCardSize(CardSize cardSize) {
    state = state.copyWith(cardSize: cardSize);
  }
}

/// Provider for modal states
final modalStateProvider = StateNotifierProvider<ModalStateNotifier, ModalState>((ref) {
  return ModalStateNotifier();
});

/// Modal state model
class ModalState {
  const ModalState({
    this.showFilterModal = false,
    this.showSortModal = false,
    this.showExportModal = false,
    this.showSettingsModal = false,
    this.showHelpModal = false,
  });

  final bool showFilterModal;
  final bool showSortModal;
  final bool showExportModal;
  final bool showSettingsModal;
  final bool showHelpModal;

  ModalState copyWith({
    bool? showFilterModal,
    bool? showSortModal,
    bool? showExportModal,
    bool? showSettingsModal,
    bool? showHelpModal,
  }) {
    return ModalState(
      showFilterModal: showFilterModal ?? this.showFilterModal,
      showSortModal: showSortModal ?? this.showSortModal,
      showExportModal: showExportModal ?? this.showExportModal,
      showSettingsModal: showSettingsModal ?? this.showSettingsModal,
      showHelpModal: showHelpModal ?? this.showHelpModal,
    );
  }
}

/// State notifier for modal states
class ModalStateNotifier extends StateNotifier<ModalState> {
  ModalStateNotifier() : super(const ModalState());

  void showFilterModal() {
    state = state.copyWith(showFilterModal: true);
  }

  void hideFilterModal() {
    state = state.copyWith(showFilterModal: false);
  }

  void showSortModal() {
    state = state.copyWith(showSortModal: true);
  }

  void hideSortModal() {
    state = state.copyWith(showSortModal: false);
  }

  void showExportModal() {
    state = state.copyWith(showExportModal: true);
  }

  void hideExportModal() {
    state = state.copyWith(showExportModal: false);
  }

  void showSettingsModal() {
    state = state.copyWith(showSettingsModal: true);
  }

  void hideSettingsModal() {
    state = state.copyWith(showSettingsModal: false);
  }

  void showHelpModal() {
    state = state.copyWith(showHelpModal: true);
  }

  void hideHelpModal() {
    state = state.copyWith(showHelpModal: false);
  }

  void hideAllModals() {
    state = const ModalState();
  }
}

/// Provider for loading states
final loadingStateProvider = StateNotifierProvider<LoadingStateNotifier, Map<String, bool>>((ref) {
  return LoadingStateNotifier();
});

/// State notifier for loading states
class LoadingStateNotifier extends StateNotifier<Map<String, bool>> {
  LoadingStateNotifier() : super({});

  void setLoading(String key, bool isLoading) {
    if (isLoading) {
      state = {...state, key: true};
    } else {
      final newState = Map<String, bool>.from(state);
      newState.remove(key);
      state = newState;
    }
  }

  bool isLoading(String key) {
    return state[key] ?? false;
  }
}

/// Provider for error states
final errorStateProvider = StateNotifierProvider<ErrorStateNotifier, Map<String, String>>((ref) {
  return ErrorStateNotifier();
});

/// State notifier for error states
class ErrorStateNotifier extends StateNotifier<Map<String, String>> {
  ErrorStateNotifier() : super({});

  void setError(String key, String error) {
    state = {...state, key: error};
  }

  void clearError(String key) {
    final newState = Map<String, String>.from(state);
    newState.remove(key);
    state = newState;
  }

  void clearAllErrors() {
    state = {};
  }

  String? getError(String key) {
    return state[key];
  }

  bool hasError(String key) {
    return state.containsKey(key);
  }
}

/// Provider for snackbar messages
final snackbarProvider = StateNotifierProvider<SnackbarNotifier, SnackbarState?>((ref) {
  return SnackbarNotifier();
});

/// Snackbar state model
class SnackbarState {
  const SnackbarState({
    required this.message,
    this.type = SnackbarType.info,
    this.duration = const Duration(seconds: 3),
    this.action,
  });

  final String message;
  final SnackbarType type;
  final Duration duration;
  final SnackBarAction? action;
}

enum SnackbarType {
  info,
  success,
  warning,
  error,
}

/// State notifier for snackbar messages
class SnackbarNotifier extends StateNotifier<SnackbarState?> {
  SnackbarNotifier() : super(null);

  void showSnackbar({
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    state = SnackbarState(
      message: message,
      type: type,
      duration: duration,
      action: action,
    );
  }

  void showSuccess(String message, {SnackBarAction? action}) {
    showSnackbar(
      message: message,
      type: SnackbarType.success,
      action: action,
    );
  }

  void showError(String message, {SnackBarAction? action}) {
    showSnackbar(
      message: message,
      type: SnackbarType.error,
      duration: const Duration(seconds: 5),
      action: action,
    );
  }

  void showWarning(String message, {SnackBarAction? action}) {
    showSnackbar(
      message: message,
      type: SnackbarType.warning,
      action: action,
    );
  }

  void hide() {
    state = null;
  }
}

/// Provider for camera state
final cameraStateProvider = StateNotifierProvider<CameraStateNotifier, CameraState>((ref) {
  return CameraStateNotifier();
});

/// Camera state model
class CameraState {
  const CameraState({
    this.isInitialized = false,
    this.isFlashOn = false,
    this.isFrontCamera = false,
    this.currentZoom = 1.0,
    this.minZoom = 1.0,
    this.maxZoom = 10.0,
    this.showGrid = false,
    this.lastPhotoPath,
    this.error,
  });

  final bool isInitialized;
  final bool isFlashOn;
  final bool isFrontCamera;
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final bool showGrid;
  final String? lastPhotoPath;
  final String? error;

  CameraState copyWith({
    bool? isInitialized,
    bool? isFlashOn,
    bool? isFrontCamera,
    double? currentZoom,
    double? minZoom,
    double? maxZoom,
    bool? showGrid,
    String? lastPhotoPath,
    String? error,
  }) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      currentZoom: currentZoom ?? this.currentZoom,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      showGrid: showGrid ?? this.showGrid,
      lastPhotoPath: lastPhotoPath ?? this.lastPhotoPath,
      error: error ?? this.error,
    );
  }
}

/// State notifier for camera state
class CameraStateNotifier extends StateNotifier<CameraState> {
  CameraStateNotifier() : super(const CameraState());

  void setInitialized(bool initialized) {
    state = state.copyWith(isInitialized: initialized);
  }

  void toggleFlash() {
    state = state.copyWith(isFlashOn: !state.isFlashOn);
  }

  void toggleCamera() {
    state = state.copyWith(isFrontCamera: !state.isFrontCamera);
  }

  void setZoom(double zoom) {
    state = state.copyWith(currentZoom: zoom.clamp(state.minZoom, state.maxZoom));
  }

  void setZoomLimits(double min, double max) {
    state = state.copyWith(minZoom: min, maxZoom: max);
  }

  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  void setLastPhotoPath(String path) {
    state = state.copyWith(lastPhotoPath: path);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = const CameraState();
  }
}

/// Provider for app lifecycle state
final appLifecycleProvider = StateProvider<AppLifecycleState>((ref) => AppLifecycleState.resumed);

/// Provider for connectivity state
final connectivityProvider = StateProvider<bool>((ref) => true);

/// Provider for performance metrics
final performanceMetricsProvider = StateNotifierProvider<PerformanceMetricsNotifier, PerformanceMetrics>((ref) {
  return PerformanceMetricsNotifier();
});

/// Performance metrics model
class PerformanceMetrics {
  const PerformanceMetrics({
    this.frameRate = 60.0,
    this.memoryUsage = 0.0,
    this.loadTime = Duration.zero,
    this.navigationTime = Duration.zero,
  });

  final double frameRate;
  final double memoryUsage; // MB
  final Duration loadTime;
  final Duration navigationTime;

  PerformanceMetrics copyWith({
    double? frameRate,
    double? memoryUsage,
    Duration? loadTime,
    Duration? navigationTime,
  }) {
    return PerformanceMetrics(
      frameRate: frameRate ?? this.frameRate,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      loadTime: loadTime ?? this.loadTime,
      navigationTime: navigationTime ?? this.navigationTime,
    );
  }
}

/// State notifier for performance metrics
class PerformanceMetricsNotifier extends StateNotifier<PerformanceMetrics> {
  PerformanceMetricsNotifier() : super(const PerformanceMetrics());

  void updateFrameRate(double frameRate) {
    state = state.copyWith(frameRate: frameRate);
  }

  void updateMemoryUsage(double memoryUsage) {
    state = state.copyWith(memoryUsage: memoryUsage);
  }

  void updateLoadTime(Duration loadTime) {
    state = state.copyWith(loadTime: loadTime);
  }

  void updateNavigationTime(Duration navigationTime) {
    state = state.copyWith(navigationTime: navigationTime);
  }
}