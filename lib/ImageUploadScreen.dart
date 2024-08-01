import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yolo_app/DetectionResult.dart';
import 'package:http/http.dart' as http;
import 'package:yolo_app/ImageWithBoxes.dart';


class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  List<DetectionResult>? _results;

  Future<void> _pickImage(ImageSource camera) async {
    final pickedFile = await ImagePicker().getImage(source: camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _results = null; // Reset results when a new image is picked
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final uri = Uri.parse('http://192.168.2.131:5000/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print('Response Body: $responseBody'); // Debugging line
      final results = parseResults(responseBody);
      setState(() {
        _results = results;
      });
    } else {
      print('Image upload failed');
    }
  }

  List<DetectionResult> parseResults(String responseBody) {
  final parsedJson = jsonDecode(responseBody);
  if (parsedJson['results'] is String) {
    final resultsString = parsedJson['results'] as String;
    final resultsList = jsonDecode(resultsString) as List;
    return resultsList.map<DetectionResult>((json) => DetectionResult.fromJson(json)).toList();
  } else if (parsedJson['results'] is List) {
    final parsed = parsedJson['results'] as List;
    return parsed.map<DetectionResult>((json) => DetectionResult.fromJson(json)).toList();
  } else {
    throw Exception('Unexpected JSON format');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yolo demo"),
      ),
      body: Center(
        child: Column(
          children: [
            if (_image != null)
              Expanded(
                child: _results == null
                    ? Image.file(_image!)
                    : ImageWithBoxes(imagePath: _image!.path, results: _results!),
              ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text('Pick Image from Camera'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text('Pick Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}