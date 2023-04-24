import 'package:flutter/material.dart';

import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/values.dart';

class PdfPreview extends StatefulWidget {
  final String pdfUrl;

  const PdfPreview({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Values.cardRadius),
          border: Border.all(color: AppColor.blueActive, width: 4)),
      height: 400,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Values.cardRadius - 4),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: InteractiveViewer(
              child: PDF(
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: false,
                onError: (error) {
                  print(error.toString());
                },
                onPageError: (page, error) {
                  print('$page: ${error.toString()}');
                },
              ).fromAsset('assets/pdf/sample.pdf'),
            ),
          ),
        ),
      ),
    );
  }
}
