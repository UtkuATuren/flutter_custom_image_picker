// gallery_provider.dart
// Manages fetching albums and paginated assets from the device gallery.

import 'dart:async';
import 'package:custom_image_picker_test/models/gallery_state.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gallery_provider.g.dart';

@riverpod
class Gallery extends _$Gallery {
  @override
  Future<GalleryState> build() async {
    // Fetch all albums and the first page of assets from the "Recents" album.
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );
    if (albums.isEmpty) {
      return GalleryState(albums: [], assets: [], selectedAlbum: null);
    }

    final recentAlbum = albums.first;
    final assets = await recentAlbum.getAssetListPaged(page: 0, size: 60);

    return GalleryState(
      albums: albums,
      assets: assets,
      selectedAlbum: recentAlbum,
      currentPage: 0,
    );
  }

  // Loads more assets for the currently selected album (infinite scrolling).
  Future<void> loadMoreAssets() async {
    final currentState = state.value;
    if (currentState == null || currentState.selectedAlbum == null) return;

    final nextPage = currentState.currentPage + 1;
    final newAssets = await currentState.selectedAlbum!.getAssetListPaged(
      page: nextPage,
      size: 60,
    );

    if (newAssets.isNotEmpty) {
      state = AsyncData(
        currentState.copyWith(
          assets: [...currentState.assets, ...newAssets],
          currentPage: nextPage,
        ),
      );
    }
  }

  // Changes the selected album and loads its assets.
  Future<void> selectAlbum(AssetPathEntity album) async {
    state = const AsyncValue.loading();
    final assets = await album.getAssetListPaged(page: 0, size: 60);
    state = AsyncData(
      state.value!.copyWith(
        selectedAlbum: album,
        assets: assets,
        currentPage: 0,
      ),
    );
  }
}
