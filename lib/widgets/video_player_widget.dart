// video_player_widget.dart
// Widget for playing and trimming videos

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.asset,
    this.startTime,
    this.endTime,
    this.onTrimChanged,
  });

  final AssetEntity asset;
  final Duration? startTime;
  final Duration? endTime;
  final void Function(Duration startTime, Duration endTime)? onTrimChanged;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final Trimmer _trimmer = Trimmer();
  bool _isLoaded = false;
  bool _isPlaying = false;
  String? _errorMessage;
  double _startValue = 0.0;
  double _endValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    try {
      final file = await widget.asset.file;
      if (file == null) {
        setState(() {
          _errorMessage = 'Could not load video file';
        });
        return;
      }

      await _trimmer.loadVideo(videoFile: file);
      setState(() {
        _isLoaded = true;
        // Set initial trim values if provided
        if (widget.startTime != null) {
          _startValue = widget.startTime!.inMilliseconds.toDouble();
        }
        if (widget.endTime != null) {
          _endValue = widget.endTime!.inMilliseconds.toDouble();
        } else {
          // Set end value to video duration if not specified
          _endValue = (widget.asset.duration * 1000).toDouble();
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading video: $e';
      });
    }
  }

  void _onTrimChanged(double startValue, double endValue) {
    setState(() {
      _startValue = startValue;
      _endValue = endValue;
    });

    final startTime = Duration(milliseconds: startValue.toInt());
    final endTime = Duration(milliseconds: endValue.toInt());
    widget.onTrimChanged?.call(startTime, endTime);
  }

  Future<void> _togglePlayPause() async {
    try {
      final playbackState = await _trimmer.videoPlaybackControl(
        startValue: _startValue,
        endValue: _endValue,
      );
      setState(() {
        _isPlaying = playbackState;
      });
    } catch (e) {
      print('Error controlling playback: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isLoaded) {
      return Container(
        height: 300,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      height: 300,
      child: Column(
        children: [
          // Video display
          Expanded(
            child: Stack(
              children: [
                VideoViewer(trimmer: _trimmer),

                // Play/pause button overlay
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _isPlaying ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trimmer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TrimViewer(
                  trimmer: _trimmer,
                  viewerHeight: 20.0,
                  viewerWidth: MediaQuery.of(context).size.width,
                  durationStyle: DurationStyle.FORMAT_MM_SS,
                  areaProperties: TrimAreaProperties.edgeBlur(),
                  onChangeStart: (value) => _onTrimChanged(value, _endValue),
                  onChangeEnd: (value) => _onTrimChanged(_startValue, value),
                  onChangePlaybackState: (value) {
                    setState(() {
                      _isPlaying = value;
                    });
                  },
                ),

                const SizedBox(height: 8),

                // Display current trim times
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Start: ${Duration(milliseconds: _startValue.toInt()).toString().substring(2, 7)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'End: ${Duration(milliseconds: _endValue.toInt()).toString().substring(2, 7)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
