import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for voice recording functionality with waveform visualization
/// Enables audio field observations with real-time recording controls
class VoiceRecordingWidget extends StatefulWidget {
  final ValueChanged<String>? onRecordingComplete;
  final VoidCallback? onRecordingCancelled;

  const VoiceRecordingWidget({
    super.key,
    this.onRecordingComplete,
    this.onRecordingCancelled,
  });

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  List<double> _waveformData = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _requestPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _requestPermission() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      // Handle permission denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Microphone permission is required for voice recording'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          SizedBox(height: 3.h),
          _buildWaveformVisualization(context),
          SizedBox(height: 3.h),
          _buildRecordingTimer(context),
          SizedBox(height: 3.h),
          _buildRecordingControls(context),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        CustomIconWidget(
          iconName: 'mic',
          size: 24,
          color: colorScheme.primary,
        ),
        SizedBox(width: 3.w),
        Text(
          'Voice Recording',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            if (_isRecording) {
              _stopRecording();
            }
            widget.onRecordingCancelled?.call();
          },
          icon: CustomIconWidget(
            iconName: 'close',
            size: 24,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveformVisualization(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 15.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: _isRecording
          ? CustomPaint(
              painter: WaveformPainter(
                waveformData: _waveformData,
                color: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainerHigh,
              ),
              child: Container(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'graphic_eq',
                    size: 48,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Waveform will appear here',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRecordingTimer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _isRecording
            ? colorScheme.primary.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: _isRecording
            ? Border.all(color: colorScheme.primary, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isRecording) ...[
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 2.w),
          ],
          Text(
            _formatDuration(_recordingDuration),
            style: theme.textTheme.titleMedium?.copyWith(
              color: _isRecording ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingControls(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Cancel button
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: colorScheme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (_isRecording) {
                  _stopRecording();
                }
                widget.onRecordingCancelled?.call();
              },
              borderRadius: BorderRadius.circular(15.w),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'close',
                  size: 24,
                  color: colorScheme.error,
                ),
              ),
            ),
          ),
        ),

        // Record/Stop button
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRecording ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color:
                        _isRecording ? colorScheme.error : colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? colorScheme.error
                                : colorScheme.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _isRecording ? 'stop' : 'mic',
                      size: 32,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Pause/Resume button
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: _isRecording
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(
              color: _isRecording
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isRecording
                  ? (_isPaused ? _resumeRecording : _pauseRecording)
                  : null,
              borderRadius: BorderRadius.circular(15.w),
              child: Center(
                child: CustomIconWidget(
                  iconName: _isPaused ? 'play_arrow' : 'pause',
                  size: 24,
                  color: _isRecording
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _showPermissionError();
        return;
      }

      await _audioRecorder.start(const RecordConfig(), path: 'recording.m4a');

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _recordingDuration = Duration.zero;
      });

      _pulseController.repeat(reverse: true);
      _startTimer();
      _simulateWaveform();
    } catch (e) {
      _showRecordingError();
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _isPaused = false;
      });

      _pulseController.stop();
      _timer?.cancel();

      if (path != null) {
        widget.onRecordingComplete?.call(path);
      }
    } catch (e) {
      _showRecordingError();
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _audioRecorder.pause();
      setState(() {
        _isPaused = true;
      });
      _pulseController.stop();
      _timer?.cancel();
    } catch (e) {
      _showRecordingError();
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _audioRecorder.resume();
      setState(() {
        _isPaused = false;
      });
      _pulseController.repeat(reverse: true);
      _startTimer();
    } catch (e) {
      _showRecordingError();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _simulateWaveform() {
    // Simulate waveform data for visualization
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording || _isPaused) {
        timer.cancel();
        return;
      }

      setState(() {
        _waveformData
            .add((DateTime.now().millisecondsSinceEpoch % 100) / 100.0);
        if (_waveformData.length > 50) {
          _waveformData.removeAt(0);
        }
      });
    });
  }

  void _showPermissionError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRecordingError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

/// Custom painter for waveform visualization
class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final Color backgroundColor;

  WaveformPainter({
    required this.waveformData,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (waveformData.isEmpty) return;

    final path = Path();
    final stepWidth = size.width / waveformData.length;

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * stepWidth;
      final y = size.height / 2 + (waveformData[i] - 0.5) * size.height * 0.8;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
