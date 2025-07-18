// gallery_grid_item.dart
// A highly optimized widget for displaying a single asset in the grid.

import 'package:custom_image_picker_test/widgets/asset_entity_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../providers/selection_provider.dart';

class GalleryGridItem extends HookConsumerWidget {
  final AssetEntity asset;

  const GalleryGridItem({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(selectionProvider.select(
      (s) => s.any((selected) => selected.asset.id == asset.id),
    ));
    final selectionOrder = ref.watch(selectionProvider.select((s) {
      final index = s.indexWhere((selected) => selected.asset.id == asset.id);
      return index != -1 ? index + 1 : null;
    }));

    return GestureDetector(
      onTap: () => ref.read(selectionProvider.notifier).toggleAsset(asset),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The main asset thumbnail
          AssetEntityImage(
            asset,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(200),
            fit: BoxFit.cover,
          ),
          // Video duration indicator
          if (asset.type == AssetType.video)
            Positioned(
              bottom: 4,
              right: 4,
              child: Text(
                _formatDuration(asset.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Selection overlay
          if (isSelected)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    '$selectionOrder',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
