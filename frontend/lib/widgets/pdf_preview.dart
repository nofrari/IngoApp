import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/widgets/popup.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:frontend/widgets/text_google.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/widgets/button.dart';
import 'package:path_provider/path_provider.dart';

class PdfPreview extends StatefulWidget {
  String? pdfUrl;

  PdfPreview({Key? key, this.pdfUrl}) : super(key: key);

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  List<File> _selectedImages = [];
  File? _pdfFile;
  bool _showPdf = true;
  double containerHeight = 0;

  void _deletePdf() async {
    setState(() {
      _showPdf = false;
    });

    if (_pdfFile != null) {
      try {
        await _pdfFile!.delete();
        setState(() {
          _pdfFile = null;
        });
        _resetImages();
      } catch (e) {
        print('Error deleting PDF file: $e');
      }
    } else {
      setState(() {
        widget.pdfUrl = null;
      });
    }
  }

  void _addPdf(String? variant) async {
    if (variant == "gallery") {
      await _pickImages();
    } else if (variant == "camera") {
      await _takeImages();
    }
    setState(() {
      _showPdf = true;
    });

    await _generatePdf();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles == null) return;

    setState(() {
      _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  Future<void> _takeImages() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() {
      _selectedImages = [File(pickedFile.path)];
    });
  }

  void _resetImages() {
    setState(() {
      _selectedImages = [];
    });
  }

  Future<void> _generatePdf() async {
    final doc = pdf.Document();

    for (final image in _selectedImages) {
      final img = pdf.MemoryImage(image.readAsBytesSync());
      doc.addPage(pdf.Page(
        build: (context) => pdf.Center(child: pdf.Image(img)),
      ));
    }

    final output = await getTemporaryDirectory();
    final fileName = 'pdf_file_${Random().nextInt(100000)}.pdf';
    final file = File('${output.path}/$fileName');
    final bytes = await doc.save();
    await file.writeAsBytes(bytes);

    setState(() {
      _pdfFile = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_pdfFile != null || widget.pdfUrl != null) && _showPdf
        ? Container(
            height: 400,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Values.cardRadius),
                border: Border.all(color: AppColor.blueActive, width: 2)),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Values.cardRadius - 4),
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) =>
                              Container(
                        height: containerHeight > 0 ? containerHeight : 800,
                        child: InteractiveViewer(
                          clipBehavior: Clip.none,
                          constrained: true,
                          child: PDF(
                            enableSwipe: true,
                            swipeHorizontal: false,
                            autoSpacing: true,
                            pageFling: false,
                            fitPolicy: FitPolicy.WIDTH,
                            fitEachPage: false,
                            pageSnap: false,
                            onError: (error) {
                              print(error.toString());
                            },
                            onPageError: (page, error) {
                              print('$page: ${error.toString()}');
                            },
                          ).fromAsset(widget.pdfUrl ?? _pdfFile!.path),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: RoundButton(
                    icon: Icons.delete,
                    onTap: _deletePdf,
                  ),
                ),
              ],
            ),
          )
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: TextGoogle(
                    align: TextAlign.start,
                    text: "Foto der Rechnung hochladen",
                    style: Fonts.popupText,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RoundButton(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => PopUp(
                              content: '',
                              actions: [
                                Container(
                                  margin: Values.buttonPadding,
                                  child: Column(
                                    children: [
                                      Button(
                                          btnText: "CAMERA",
                                          onTap: () {
                                            _addPdf("camera");
                                            Navigator.pop(context);
                                          },
                                          theme: ButtonColorTheme.secondary),
                                      Button(
                                          btnText: "GALLERY",
                                          onTap: () {
                                            _addPdf("gallery");
                                            Navigator.pop(context);
                                          },
                                          theme: ButtonColorTheme.secondary),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icons.add),
                    TextGoogle(
                      align: TextAlign.start,
                      text: "Keine Datei ausgewählt",
                      style: Fonts.popupText,
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
