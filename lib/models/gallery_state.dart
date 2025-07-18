// gallery_models.dart
// Defines the data models used by the providers.

import 'package:photo_manager/photo_manager.dart';

class GalleryState {
  final List<AssetPathEntity> albums;
  final List<AssetEntity> assets;
  final AssetPathEntity? selectedAlbum;
  final int currentPage;

  GalleryState({
    required this.albums,
    required this.assets,
    this.selectedAlbum,
    this.currentPage = 0,
  });

  GalleryState copyWith({
    List<AssetPathEntity>? albums,
    List<AssetEntity>? assets,
    AssetPathEntity? selectedAlbum,
    int? currentPage,
  }) {
    return GalleryState(
      albums: albums ?? this.albums,
      assets: assets ?? this.assets,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
