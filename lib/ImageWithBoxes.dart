import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yolo_app/DetectionResult.dart';

class ImageWithBoxes extends StatelessWidget {
  final String imagePath;
  final List<DetectionResult> results;

  ImageWithBoxes({required this.imagePath, required this.results});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final image = Image.file(File(imagePath));
        return FutureBuilder<Size>(
          future: _getImageSize(image),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final imageSize = snapshot.data!;
            final scaleX = constraints.maxWidth / imageSize.width;
            final scaleY = constraints.maxHeight / imageSize.height;

            return Stack(
              fit: StackFit.expand,
              children: [
                image,
                ...results.map((result) {
                  final left = result.xmin * scaleX;
                  final top = result.ymin * scaleY;
                  final width = (result.xmax - result.xmin) * scaleX;
                  final height = (result.ymax - result.ymin) * scaleY;

                  return Positioned(
                    left: left,
                    top: top,
                    width: width,
                    height: height,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '${result.name} ${(result.confidence * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            backgroundColor: Colors.red,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Future<Size> _getImageSize(Image image) {
    final completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()));
      }),
    );
    return completer.future;
  }
}
