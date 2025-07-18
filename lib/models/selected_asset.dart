// gallery_models.dart
// Defines the data models used by the providers.

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

// Represents an asset that has been selected by the user,
// including any editing information like aspect ratio and transform.
class SelectedAsset {
  final AssetEntity asset;
  final double? aspectRatio;
  final double scale;
  final Offset translation;

  // Video trimming properties
  final Duration? startTime;
  final Duration? endTime;

  SelectedAsset({
    required this.asset,
    this.aspectRatio,
    this.scale = 1.0,
    this.translation = Offset.zero,
    this.startTime,
    this.endTime,
  });

  SelectedAsset copyWith({
    AssetEntity? asset,
    double? aspectRatio,
    double? scale,
    Offset? translation,
    Duration? startTime,
    Duration? endTime,
  }) {
    return SelectedAsset(
      asset: asset ?? this.asset,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      scale: scale ?? this.scale,
      translation: translation ?? this.translation,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
