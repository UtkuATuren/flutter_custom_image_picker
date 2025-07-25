// selection_provider.dart
// Manages the synchronous state of selected assets.

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/selected_asset.dart';

part 'selection_provider.g.dart';

@riverpod
class Selection extends _$Selection {
  @override
  List<SelectedAsset> build() {
    // The initial state is an empty list.
    return [];
  }

  // Toggles the selection status of an asset.
  void toggleAsset(AssetEntity asset) {
    final isSelected = state.any((selected) => selected.asset.id == asset.id);
    if (isSelected) {
      state = state.where((selected) => selected.asset.id != asset.id).toList();
    } else {
      state = [...state, SelectedAsset(asset: asset)];
    }
  }

  // Reorders the list of selected assets.
  void reorder(int oldIndex, int newIndex) {
    final item = state.removeAt(oldIndex);
    state.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    // We need to create a new list to trigger a state update.
    state = [...state];
  }

  // Updates the aspect ratio for a specific asset.
  void updateAspectRatio(AssetEntity asset, double? ratio) {
    state = [
      for (final selectedAsset in state)
        if (selectedAsset.asset.id == asset.id) selectedAsset.copyWith(aspectRatio: ratio) else selectedAsset
    ];
  }

  // Updates the transform (scale and translation) for a specific asset.
  void updateTransform(AssetEntity asset, double scale, Offset translation) {
    state = [
      for (final selectedAsset in state)
        if (selectedAsset.asset.id == asset.id) selectedAsset.copyWith(scale: scale, translation: translation) else selectedAsset
    ];
  }

  // Updates the video trimming times for a specific asset.
  void updateVideoTrim(AssetEntity asset, Duration startTime, Duration endTime) {
    state = [
      for (final selectedAsset in state)
        if (selectedAsset.asset.id == asset.id) selectedAsset.copyWith(startTime: startTime, endTime: endTime) else selectedAsset
    ];
  }

  // Checks if an asset is currently selected.
  bool isSelected(AssetEntity asset) {
    return state.any((selected) => selected.asset.id == asset.id);
  }

  // Clears the entire selection.
  void clear() {
    state = [];
  }
}
