// foldable_preview_widget.dart
// A collapsible widget that shows previews of selected assets

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/selected_asset.dart';
import '../providers/selection_provider.dart';
import '../screens/gallery_editor_screen.dart';
import '../widgets/asset_entity_image.dart';

class FoldablePreviewWidget extends HookConsumerWidget {
  const FoldablePreviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAssets = ref.watch(selectionProvider);

    // Don't show if no items are selected
    if (selectedAssets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        leading: const Icon(Icons.photo_library),
        title: Text('Selected Items (${selectedAssets.length})'),
        initiallyExpanded: false,
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedAssets.length,
              itemBuilder: (context, index) {
                final selectedAsset = selectedAssets[index];

                return _PreviewItem(
                  key: ValueKey(selectedAsset.asset.id),
                  selectedAsset: selectedAsset,
                  index: index,
                );
              },
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ref.read(selectionProvider.notifier).clear();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GalleryEditorScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewItem extends HookConsumerWidget {
  const _PreviewItem({
    super.key,
    required this.selectedAsset,
    required this.index,
  });

  final SelectedAsset selectedAsset;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2.0,
        ),
      ),
      child: Stack(
        children: [
          // Asset thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: AssetEntityImage(
                selectedAsset.asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(200),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Video duration indicator for videos
          if (selectedAsset.asset.type == AssetType.video)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  _formatDuration(selectedAsset.asset.duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Selection order badge
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                ref.read(selectionProvider.notifier).toggleAsset(selectedAsset.asset);
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),

          // Asset type indicator
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Icon(
                selectedAsset.asset.type == AssetType.video ? Icons.videocam : Icons.photo,
                color: Colors.white,
                size: 12,
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
