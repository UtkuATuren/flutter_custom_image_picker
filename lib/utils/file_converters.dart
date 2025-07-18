// file_converters.dart
// Helper function to bridge the gap between photo_manager and image_picker types.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

// Converts an AssetEntity from photo_manager to an XFile.
// Returns null if the asset file cannot be retrieved.
Future<XFile?> convertAssetEntityToXFile(AssetEntity entity) async {
  final File? file = await entity.file;
  if (file == null) {
    // This can happen if the asset is in the cloud and cannot be downloaded.
    debugPrint('Error: Could not retrieve file for asset ${entity.id}');
    return null;
  }
  return XFile(file.path);
}
