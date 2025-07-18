// gallery_editor_screen.dart
// The second page for reordering and editing selected assets.

import 'package:custom_image_picker_test/providers/selection_provider.dart';
import 'package:custom_image_picker_test/widgets/aspect_ratio_widget.dart';
import 'package:custom_image_picker_test/widgets/asset_entity_image.dart';
import 'package:custom_image_picker_test/widgets/video_player_widget.dart';
import 'package:custom_image_picker_test/utils/file_converters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_trimmer/video_trimmer.dart';

class GalleryEditorScreen extends HookConsumerWidget {
  const GalleryEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAssets = ref.watch(selectionProvider);
    final isProcessing = useState(false);
    final currentPageIndex = useState(0);

    // We use a PageController to get page turning animations and to easily track the current page.
    final pageController = usePageController();

    // Listen to page changes
    useEffect(() {
      void listener() {
        currentPageIndex.value = pageController.page?.round() ?? 0;
      }

      pageController.addListener(listener);
      return () => pageController.removeListener(listener);
    }, [pageController]);

    // Aspect ratio options.
    final aspectRatios = {
      'Free': null,
      '1:1': 1.0,
      '3:4': 3.0 / 4.0,
      '4:3': 4.0 / 3.0,
      '9:16': 9.0 / 16.0,
      '16:9': 16.0 / 9.0,
    };

    // This ensures the selection provider is cleared when the user leaves
    // the picker flow without completing it.
    useEffect(() {
      return () {
        // This function is called when the widget is disposed.
        Future.microtask(() => ref.read(selectionProvider.notifier).clear());
      };
    }, const []);

    Future<void> onDone() async {
      isProcessing.value = true;
      try {
        final finalFiles = <XFile>[];
        for (final selectedAsset in selectedAssets) {
          final file = await selectedAsset.asset.file;
          if (file == null) continue;

          String filePath = file.path;

          // Handle video trimming
          if (selectedAsset.asset.type == AssetType.video && (selectedAsset.startTime != null && selectedAsset.endTime != null)) {
            final trimmer = Trimmer();
            try {
              await trimmer.loadVideo(videoFile: file);
              String? trimmedPath;
              await trimmer.saveTrimmedVideo(
                startValue: selectedAsset.startTime!.inMilliseconds.toDouble(),
                endValue: selectedAsset.endTime!.inMilliseconds.toDouble(),
                onSave: (outputPath) {
                  trimmedPath = outputPath;
                },
              );
              if (trimmedPath != null) {
                filePath = trimmedPath!;
              }
            } catch (e) {
              print('Error trimming video: $e');
            } finally {
              trimmer.dispose();
            }
          }
          // Handle image cropping
          else if (selectedAsset.asset.type == AssetType.image && selectedAsset.aspectRatio != null) {
            try {
              // Get image dimensions from the asset
              final imageSize = Size(
                selectedAsset.asset.width.toDouble(),
                selectedAsset.asset.height.toDouble(),
              );

              // Use the container size from our editor (600 pixels height)
              final containerSize = const Size(600, 600);
              final displaySize = ImageCropHelper.getImageDisplaySize(containerSize, imageSize);

              // Use our custom cropping instead of ImageCropper
              final croppedFile = await ImageCropHelper.cropImage(
                sourceFile: file,
                aspectRatio: selectedAsset.aspectRatio,
                scale: selectedAsset.scale,
                translation: selectedAsset.translation,
                imageDisplaySize: displaySize,
              );

              if (croppedFile != null) {
                filePath = croppedFile.path;
              }
            } catch (e) {
              print('Error cropping image: $e');
              // If cropping fails, use original file
            }
          }
          finalFiles.add(XFile(filePath));
        }
        // Pop twice to exit the picker flow completely.
        if (context.mounted) {
          Navigator.of(context)
            ..pop()
            ..pop(finalFiles);
        }
      } finally {
        isProcessing.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit & Reorder (${currentPageIndex.value + 1}/${selectedAssets.length})'),
        actions: [
          if (isProcessing.value)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: selectedAssets.isEmpty ? null : onDone,
              child: const Text('Done'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main reorderable image preview area.
            SizedBox(
              height: 600, // Fixed height for images
              child: PageView.builder(
                controller: pageController,
                itemCount: selectedAssets.length,
                itemBuilder: (context, index) {
                  final selectedAsset = selectedAssets[index];
                  return Card(
                    key: ValueKey(selectedAsset.asset.id),
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(),
                    child: selectedAsset.asset.type == AssetType.video
                        ? VideoPlayerWidget(
                            asset: selectedAsset.asset,
                            startTime: selectedAsset.startTime,
                            endTime: selectedAsset.endTime,
                            onTrimChanged: (startTime, endTime) {
                              ref.read(selectionProvider.notifier).updateVideoTrim(
                                    selectedAsset.asset,
                                    startTime,
                                    endTime,
                                  );
                            },
                          )
                        : AspectRatioPreviewWrapper(
                            aspectRatio: selectedAsset.aspectRatio,
                            onTransformChanged: (scale, translation) {
                              // Update the transform for the current asset
                              ref.read(selectionProvider.notifier).updateTransform(
                                    selectedAsset.asset,
                                    scale,
                                    translation,
                                  );
                            },
                            child: AssetEntityImage(
                              selectedAsset.asset,
                              isOriginal: true,
                              fit: BoxFit.contain,
                            ),
                          ),
                  );
                },
              ),
            ),

            // Transform info display
            if (selectedAssets.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Zoom: ${selectedAssets[currentPageIndex.value].scale.toStringAsFixed(1)}x',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Pan: ${selectedAssets[currentPageIndex.value].translation.dx.toInt()}, ${selectedAssets[currentPageIndex.value].translation.dy.toInt()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

            // Aspect Ratio selection controls (only for images).
            if (selectedAssets.isNotEmpty && selectedAssets[currentPageIndex.value].asset.type == AssetType.image)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 16),
                      ...aspectRatios.entries.map((entry) {
                        final currentAsset = selectedAssets[currentPageIndex.value];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: AspectRatioButton(
                            label: entry.key,
                            aspectRatio: entry.value ?? 0, // Pass a value for comparison
                            isSelected: currentAsset.aspectRatio == entry.value,
                            onPressed: () {
                              ref.read(selectionProvider.notifier).updateAspectRatio(
                                    currentAsset.asset,
                                    entry.value,
                                  );
                            },
                          ),
                        );
                      }),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
