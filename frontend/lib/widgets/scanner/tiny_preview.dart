import 'package:flutter/material.dart';
import 'package:frontend/widgets/text_google.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../constants/values.dart';
import 'dart:io';

class TinyPreview extends StatelessWidget {
  const TinyPreview(
      {required this.selectedImage,
      required this.images,
      required this.index,
      super.key});

  final String selectedImage;
  final List<String> images;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      // if the image is selected, a border is added to the image
      decoration: (selectedImage == images.elementAt(index))
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(Values.cardRadius - 15),
              border: Border.all(color: AppColor.blueLight),
            )
          : null,
      width: 42,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Values.cardRadius - 15),
        child: Image.file(File(images.elementAt(index)), fit: BoxFit.cover),
      ),
    );
  }
}
