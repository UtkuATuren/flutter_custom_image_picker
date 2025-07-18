// aspect_ratio_widgets.dart
// Contains the UI widgets for previewing the aspect ratio crop.

import 'package:flutter/material.dart';

/// A widget that overlays a darkened effect on the parts of its child
/// that will be cropped away, based on the provided aspect ratio.
/// Also supports zoom and pan gestures for positioning the crop area.
class AspectRatioPreviewWrapper extends StatefulWidget {
  const AspectRatioPreviewWrapper({
    super.key,
    required this.aspectRatio,
    required this.child,
    this.onTransformChanged,
  });

  /// The aspect ratio for the central, clear area (e.g., 16 / 9).
  /// If null, no overlay is shown.
  final double? aspectRatio;
  final Widget child;

  /// Called when the transform (scale/translation) changes
  final void Function(double scale, Offset translation)? onTransformChanged;

  @override
  State<AspectRatioPreviewWrapper> createState() => _AspectRatioPreviewWrapperState();
}

class _AspectRatioPreviewWrapperState extends State<AspectRatioPreviewWrapper> {
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    if (widget.onTransformChanged != null) {
      final matrix = _transformationController.value;
      final scale = matrix.getMaxScaleOnAxis();
      final translation = Offset(matrix.getTranslation().x, matrix.getTranslation().y);
      widget.onTransformChanged!(scale, translation);
    }
  }

  void _resetTransform() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    // If no aspect ratio is defined, just show the child with zoom/pan.
    if (widget.aspectRatio == null) {
      return InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 3.0,
        constrained: false,
        child: widget.child,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // The interactive viewer with the image
            ClipRect(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 3.0,
                constrained: false,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: widget.child,
                ),
              ),
            ),

            // The darkening overlay with the crop preview
            IgnorePointer(
              child: ClipPath(
                clipper: InvertedAspectRatioClipper(aspectRatio: widget.aspectRatio!),
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),

            // Reset button
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _resetTransform,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A custom clipper that creates a "hole" in a rectangle, with the hole's
/// dimensions determined by a given aspect ratio.
class InvertedAspectRatioClipper extends CustomClipper<Path> {
  final double aspectRatio;

  InvertedAspectRatioClipper({required this.aspectRatio});

  @override
  Path getClip(Size size) {
    // Calculate the dimensions of the inner "hole" rectangle.
    double outputWidth = size.width;
    double outputHeight = outputWidth / aspectRatio;

    if (outputHeight > size.height) {
      outputHeight = size.height;
      outputWidth = outputHeight * aspectRatio;
    }

    final innerRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: outputWidth,
      height: outputHeight,
    );

    // Create a path for the outer rectangle (the full size of the widget).
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // Create a path for the inner rectangle (the "hole").
    final innerPath = Path()..addRect(innerRect);

    // Combine the paths to create a shape with a hole in it.
    return Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// A button for selecting a specific aspect ratio.
class AspectRatioButton extends StatelessWidget {
  const AspectRatioButton({
    super.key,
    required this.label,
    required this.aspectRatio,
    required this.onPressed,
    required this.isSelected,
  });

  final String label;
  final double aspectRatio;
  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.3) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
        ),
      ),
    );
  }
}
