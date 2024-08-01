import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yolo_app/DetectionResult.dart';

class ImageWithBoxes extends StatelessWidget {
  final String imagePath;
  final List<DetectionResult> results;

  ImageWithBoxes({required this.imagePath, required this.results});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.file(File(imagePath)),
        ...results.map((result) {
          return Positioned(
            left: result.xmin,
            top: result.ymin,
            width: result.xmax - result.xmin,
            height: result.ymax - result.ymin,
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
  }
}