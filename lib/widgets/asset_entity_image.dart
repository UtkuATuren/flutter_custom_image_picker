import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

/// A widget that displays an [AssetEntity] image.
///
/// The widget uses [AssetEntityImageProvider] internally to resolve assets.
class AssetEntityImage extends Image {
  AssetEntityImage(
    AssetEntity entity, {
    bool isOriginal = true,
    ThumbnailSize? thumbnailSize = pmDefaultGridThumbnailSize,
    ThumbnailFormat thumbnailFormat = ThumbnailFormat.jpeg,
    int frame = 0,
    PMProgressHandler? progressHandler,
    super.key,
    super.frameBuilder,
    super.loadingBuilder,
    super.errorBuilder,
    super.semanticLabel,
    super.excludeFromSemantics,
    super.width,
    super.height,
    super.color,
    super.opacity,
    super.colorBlendMode,
    super.fit,
    super.alignment,
    super.repeat,
    super.centerSlice,
    super.matchTextDirection,
    super.gaplessPlayback,
    super.isAntiAlias,
    super.filterQuality = FilterQuality.low,
  }) : super(
          image: AssetEntityImageProvider(
            entity,
            isOriginal: isOriginal,
            thumbnailSize: thumbnailSize,
            thumbnailFormat: thumbnailFormat,
            frame: frame,
            progressHandler: progressHandler,
          ),
        );
}
