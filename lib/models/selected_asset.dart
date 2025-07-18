// gallery_models.dart
// Defines the data models used by the providers.

import 'package:photo_manager/photo_manager.dart';

// Represents an asset that has been selected by the user,
// including any editing information like aspect ratio.
class SelectedAsset {
  final AssetEntity asset;
  final double? aspectRatio;

  SelectedAsset({required this.asset, this.aspectRatio});

  SelectedAsset copyWith({
    AssetEntity? asset,
    double? aspectRatio,
  }) {
    return SelectedAsset(
      asset: asset ?? this.asset,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }
}
