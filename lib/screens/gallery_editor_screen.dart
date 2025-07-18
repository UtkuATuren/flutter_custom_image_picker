// gallery_editor_screen.dart
// The second page for reordering and editing selected assets.

import 'package:custom_image_picker_test/widgets/asset_entity_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../selection_provider.dart';

class GalleryEditorScreen extends HookConsumerWidget {
  const GalleryEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAssets = ref.watch(selectionProvider);
    final pageController = usePageController();
    final isProcessing = useState(false);

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

          if (selectedAsset.aspectRatio != null) {
            final croppedFile = await ImageCropper().cropImage(
              sourcePath: file.path,
              aspectRatio: CropAspectRatio(ratioX: selectedAsset.aspectRatio!, ratioY: 1),
              uiSettings: [
                AndroidUiSettings(toolbarTitle: 'Crop', toolbarColor: Colors.deepPurple, toolbarWidgetColor: Colors.white, initAspectRatio: CropAspectRatioPreset.original, lockAspectRatio: true),
                IOSUiSettings(
                  title: 'Crop',
                  aspectRatioLockEnabled: true,
                ),
              ],
            );
            if (croppedFile != null) {
              filePath = croppedFile.path;
            }
          }
          finalFiles.add(XFile(filePath));
        }
        // Pop twice to exit the picker flow completely
        Navigator.of(context)
          ..pop()
          ..pop(finalFiles);
      } finally {
        isProcessing.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit & Reorder'),
        actions: [
          if (isProcessing.value)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
            )
          else
            TextButton(
              onPressed: onDone,
              child: const Text('Done'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: pageController,
              itemCount: selectedAssets.length,
              itemBuilder: (context, index) {
                final selectedAsset = selectedAssets[index];
                return AssetEntityImage(
                  selectedAsset.asset,
                  isOriginal: true,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
          SizedBox(
            height: 120,
            child: ReorderableGridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: selectedAssets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                final selectedAsset = selectedAssets[index];
                return GestureDetector(
                  key: ValueKey(selectedAsset.asset.id),
                  onTap: () => pageController.jumpToPage(index),
                  child: AssetEntityImage(
                    selectedAsset.asset,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(200),
                    fit: BoxFit.cover,
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                ref.read(selectionProvider.notifier).reorder(oldIndex, newIndex);
              },
            ),
          ),
        ],
      ),
    );
  }
}
