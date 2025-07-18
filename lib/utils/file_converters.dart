// file_converters.dart
// Utilities for converting and processing files.

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCropHelper {
  /// Crops an image based on aspect ratio, scale, and translation parameters
  /// This replicates ImageCropper functionality but programmatically
  static Future<File?> cropImage({
    required File sourceFile,
    required double? aspectRatio,
    required double scale,
    required Offset translation,
    required Size imageDisplaySize,
  }) async {
    if (aspectRatio == null) {
      // No cropping needed, return original file
      return sourceFile;
    }

    try {
      // Read the source image
      final bytes = await sourceFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;

      // Calculate crop dimensions based on aspect ratio
      final originalWidth = originalImage.width.toDouble();
      final originalHeight = originalImage.height.toDouble();

      // Calculate the crop area dimensions
      double cropWidth, cropHeight;

      if (aspectRatio >= 1.0) {
        // Landscape or square aspect ratio
        cropHeight = originalHeight;
        cropWidth = cropHeight * aspectRatio;

        if (cropWidth > originalWidth) {
          cropWidth = originalWidth;
          cropHeight = cropWidth / aspectRatio;
        }
      } else {
        // Portrait aspect ratio
        cropWidth = originalWidth;
        cropHeight = cropWidth / aspectRatio;

        if (cropHeight > originalHeight) {
          cropHeight = originalHeight;
          cropWidth = cropHeight * aspectRatio;
        }
      }

      // Apply scale factor
      cropWidth = cropWidth / scale;
      cropHeight = cropHeight / scale;

      // Calculate the center point considering translation
      // Translation is relative to the display size, convert to image coordinates
      final scaleFactorX = originalWidth / imageDisplaySize.width;
      final scaleFactorY = originalHeight / imageDisplaySize.height;

      final translationX = translation.dx * scaleFactorX;
      final translationY = translation.dy * scaleFactorY;

      // Calculate crop coordinates (center the crop area and apply translation)
      final centerX = originalWidth / 2 + translationX;
      final centerY = originalHeight / 2 + translationY;

      final cropX = (centerX - cropWidth / 2).clamp(0.0, originalWidth - cropWidth);
      final cropY = (centerY - cropHeight / 2).clamp(0.0, originalHeight - cropHeight);

      // Perform the crop
      final croppedImage = img.copyCrop(
        originalImage,
        x: cropX.round(),
        y: cropY.round(),
        width: cropWidth.round(),
        height: cropHeight.round(),
      );

      // Save the cropped image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outputFile = File(path.join(tempDir.path, fileName));

      await outputFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 90));

      return outputFile;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  /// Gets the display size of an image widget for crop calculations
  static Size getImageDisplaySize(Size containerSize, Size imageSize) {
    final containerAspectRatio = containerSize.width / containerSize.height;
    final imageAspectRatio = imageSize.width / imageSize.height;

    if (imageAspectRatio > containerAspectRatio) {
      // Image is wider, fit by width
      final displayWidth = containerSize.width;
      final displayHeight = displayWidth / imageAspectRatio;
      return Size(displayWidth, displayHeight);
    } else {
      // Image is taller, fit by height
      final displayHeight = containerSize.height;
      final displayWidth = displayHeight * imageAspectRatio;
      return Size(displayWidth, displayHeight);
    }
  }
}
