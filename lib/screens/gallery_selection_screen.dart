// gallery_selection_screen.dart
// The first page of the picker for browsing and selecting assets.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'gallery_editor_screen.dart';
import '../widgets/gallery_grid_item.dart';
import '../providers/gallery_provider.dart';
import '../providers/permissions_provider.dart';
import '../providers/selection_provider.dart';

class GallerySelectionScreen extends HookConsumerWidget {
  const GallerySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    final gallery = ref.watch(galleryProvider);
    final selectedAssets = ref.watch(selectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: gallery.when(
          data: (state) => DropdownButton<AssetPathEntity>(
            value: state.selectedAlbum,
            onChanged: (album) {
              if (album != null) {
                ref.read(galleryProvider.notifier).selectAlbum(album);
              }
            },
            items: state.albums
                .map((album) => DropdownMenuItem(
                      value: album,
                      child: Text(album.name),
                    ))
                .toList(),
          ),
          loading: () => const Text('Loading...'),
          error: (e, s) => const Text('Error'),
        ),
        actions: [
          TextButton(
            onPressed: selectedAssets.isNotEmpty
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GalleryEditorScreen(),
                      ),
                    );
                  }
                : null,
            child: const Text('Next'),
          ),
        ],
      ),
      body: permissions.when(
        data: (state) {
          if (state.isAuth) {
            return gallery.when(
              data: (galleryState) {
                if (galleryState.assets.isEmpty) {
                  return const Center(child: Text('No photos found.'));
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
                      ref.read(galleryProvider.notifier).loadMoreAssets();
                    }
                    return false;
                  },
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: galleryState.assets.length,
                    itemBuilder: (context, index) {
                      final asset = galleryState.assets[index];
                      return GalleryGridItem(asset: asset);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Failed to load assets.')),
            );
          } else {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Permission denied.'),
                  ElevatedButton(
                    onPressed: () => ref.read(permissionsProvider.notifier).openSettings(),
                    child: const Text('Open Settings'),
                  )
                ],
              ),
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text('Permission request failed.')),
      ),
    );
  }
}
