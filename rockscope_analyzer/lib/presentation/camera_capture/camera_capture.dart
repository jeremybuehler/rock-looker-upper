import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/capture_controls_widget.dart';
import './widgets/focus_exposure_widget.dart';
import './widgets/metadata_panel_widget.dart';
import './widgets/stabilization_indicator_widget.dart';
import './widgets/zoom_control_widget.dart';

class CameraCapture extends StatefulWidget {
  const CameraCapture({super.key});

  @override
  State<CameraCapture> createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Camera related variables
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 10.0;

  // UI state variables
  bool _showGrid = false;
  bool _showMeasurementTools = false;
  bool _isMeasurementMode = false;
  bool _isMetadataPanelVisible = false;
  bool _isZoomControlVisible = false;
  bool _isStabilizationVisible = true;
  bool _isStable = false;
  double _stabilityLevel = 0.0;

  // Focus and exposure
  Offset? _focusPoint;
  double _exposureValue = 0.0;
  bool _isFocusExposureVisible = false;

  // Audio recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;

  // Location and metadata
  String? _currentLocation;
  String? _selectedSpecimenType;
  String? _lastPhotoPath;

  // Animation controllers
  late AnimationController _captureAnimationController;
  late Animation<double> _captureScaleAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _initializeCamera();
    _getCurrentLocation();
    _startStabilityMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _audioRecorder.dispose();
    _captureAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  void _initializeAnimations() {
    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _captureScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _captureAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) {
        _showErrorSnackBar('Camera permission denied');
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showErrorSnackBar('No cameras available');
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _applyInitialSettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to initialize camera');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _applyInitialSettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);

      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.auto);
        _minZoom = await _cameraController!.getMinZoomLevel();
        _maxZoom = await _cameraController!.getMaxZoomLevel();
        _maxZoom = _maxZoom.clamp(1.0, 10.0); // Limit to reasonable range
      }
    } catch (e) {
      // Silently handle unsupported features
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      _captureAnimationController.forward().then((_) {
        _captureAnimationController.reverse();
      });

      final XFile photo = await _cameraController!.takePicture();

      setState(() {
        _lastPhotoPath = photo.path;
      });

      // Show success feedback
      HapticFeedback.heavyImpact();
      _showSuccessSnackBar('Photo captured successfully');

      // Navigate to specimen identification after a brief delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushNamed(context, '/specimen-identification');
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to capture photo');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || kIsWeb) return;

    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newFlashMode);

      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      // Silently handle unsupported flash
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;

    try {
      final newCamera = _isFrontCamera
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            );

      await _cameraController?.dispose();

      _cameraController = CameraController(
        newCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _applyInitialSettings();

      setState(() {
        _isFrontCamera = !_isFrontCamera;
        _currentZoom = 1.0;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to switch camera');
    }
  }

  void _handleTapToFocus(TapDownDetails details) {
    if (_cameraController == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final tapPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _focusPoint = tapPosition;
      _isFocusExposureVisible = true;
    });

    // Set focus point on camera
    try {
      final double x = tapPosition.dx / renderBox.size.width;
      final double y = tapPosition.dy / renderBox.size.height;
      _cameraController!.setFocusPoint(Offset(x, y));
      _cameraController!.setExposurePoint(Offset(x, y));
    } catch (e) {
      // Silently handle unsupported focus
    }
  }

  void _handlePinchToZoom(ScaleUpdateDetails details) {
    if (_cameraController == null || kIsWeb) return;

    final newZoom = (_currentZoom * details.scale).clamp(_minZoom, _maxZoom);

    if (newZoom != _currentZoom) {
      _cameraController!.setZoomLevel(newZoom);
      setState(() {
        _currentZoom = newZoom;
        _isZoomControlVisible = true;
      });

      // Hide zoom control after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isZoomControlVisible = false;
          });
        }
      });
    }
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: 'voice_note_${DateTime.now().millisecondsSinceEpoch}.wav',
          );
        } else {
          final path =
              'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(const RecordConfig(), path: path);
        }

        setState(() {
          _isRecording = true;
        });

        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });

      HapticFeedback.lightImpact();
      _showSuccessSnackBar('Voice note saved');
    } catch (e) {
      _showErrorSnackBar('Failed to stop recording');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (kIsWeb) {
        setState(() {
          _currentLocation = 'Location: Browser-based (approximate)';
        });
        return;
      }

      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = 'Location permission denied';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = 'Lat: ${position.latitude.toStringAsFixed(6)}, '
            'Lng: ${position.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        _currentLocation = 'Unable to get location';
      });
    }
  }

  void _startStabilityMonitoring() {
    // Simulate stability monitoring
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _stabilityLevel = 0.8;
          _isStable = _stabilityLevel > 0.7;
        });
      }
    });
  }

  void _openGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _lastPhotoPath = image.path;
        });

        // Navigate to specimen identification
        Navigator.pushNamed(context, '/specimen-identification');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open gallery');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.getSuccessColor(true),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          _buildCameraPreview(),

          // Camera overlay with measurement tools
          CameraOverlayWidget(
            showGrid: _showGrid,
            showMeasurementTools: _showMeasurementTools,
            onGridToggle: () {
              setState(() {
                _showGrid = !_showGrid;
              });
            },
            onMeasurementToggle: () {
              setState(() {
                _showMeasurementTools = !_showMeasurementTools;
              });
            },
          ),

          // Top camera controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CameraControlsWidget(
              isFlashOn: _isFlashOn,
              isFrontCamera: _isFrontCamera,
              onFlashToggle: _toggleFlash,
              onCameraFlip: _flipCamera,
              onClose: () => Navigator.pop(context),
            ),
          ),

          // Bottom capture controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _captureScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _captureScaleAnimation.value,
                  child: CaptureControlsWidget(
                    isMeasurementMode: _isMeasurementMode,
                    lastPhotoPath: _lastPhotoPath,
                    onCapture: _capturePhoto,
                    onGallery: _openGallery,
                    onMeasurementToggle: () {
                      setState(() {
                        _isMeasurementMode = !_isMeasurementMode;
                        _showMeasurementTools = _isMeasurementMode;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Focus and exposure widget
          FocusExposureWidget(
            focusPoint: _focusPoint,
            exposureValue: _exposureValue,
            isVisible: _isFocusExposureVisible,
            onExposureChanged: (value) {
              setState(() {
                _exposureValue = value;
              });
              try {
                _cameraController?.setExposureOffset(value);
              } catch (e) {
                // Silently handle unsupported exposure
              }
            },
            onDismiss: () {
              setState(() {
                _isFocusExposureVisible = false;
              });
            },
          ),

          // Zoom control widget
          ZoomControlWidget(
            currentZoom: _currentZoom,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            isVisible: _isZoomControlVisible,
            onZoomChanged: (zoom) {
              setState(() {
                _currentZoom = zoom;
              });
              try {
                _cameraController?.setZoomLevel(zoom);
              } catch (e) {
                // Silently handle unsupported zoom
              }
            },
          ),

          // Stabilization indicator
          StabilizationIndicatorWidget(
            isStable: _isStable,
            stabilityLevel: _stabilityLevel,
            isVisible: _isStabilizationVisible,
          ),

          // Metadata panel
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < -500) {
                  setState(() {
                    _isMetadataPanelVisible = true;
                  });
                }
              },
              child: MetadataPanelWidget(
                isVisible: _isMetadataPanelVisible,
                currentLocation: _currentLocation,
                selectedSpecimenType: _selectedSpecimenType,
                isRecording: _isRecording,
                onClose: () {
                  setState(() {
                    _isMetadataPanelVisible = false;
                  });
                },
                onSpecimenTypeSelected: (type) {
                  setState(() {
                    _selectedSpecimenType = type;
                  });
                },
                onLocationRefresh: _getCurrentLocation,
                onVoiceNoteToggle: _toggleVoiceRecording,
              ),
            ),
          ),

          // Swipe indicator for metadata panel
          if (!_isMetadataPanelVisible)
            Positioned(
              right: 2.w,
              top: 50.h,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 1.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'keyboard_arrow_left',
                      color: Colors.white,
                      size: 4.w,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Swipe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: _handleTapToFocus,
      onScaleUpdate: _handlePinchToZoom,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CameraPreview(_cameraController!),
      ),
    );
  }
}
