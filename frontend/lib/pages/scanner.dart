import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final ImagePicker _picker = ImagePicker();
  File? imageFile;

  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageFile == null
                ? const Icon(Icons.add_photo_alternate)
                : Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.file(imageFile!, fit: BoxFit.cover),
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          _uploadImage();
                        },
                        child: const Text("UPLOAD"),
                      )
                    ],
                  ),
            FloatingActionButton(
              onPressed: () {
                _getFromGallery();
              },
              child: const Text("Pick Image from Gallery",
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  _getFromGallery() async {
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  _uploadImage() async {
    var formData = FormData.fromMap(
      {
        "image": await MultipartFile.fromFile(imageFile!.path),
      },
    );
    var response =
        await dio.post("http://10.0.2.2:3000/upload", data: formData);
    debugPrint(response.toString());
  }
}
