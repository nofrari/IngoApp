import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/widgets/popup.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:frontend/widgets/text_google.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:pdf_render/pdf_render.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/widgets/button.dart';
import 'package:path_provider/path_provider.dart';

class PdfPreview extends StatefulWidget {
  String? pdfUrl;
  int? pdfHeight;
  FocusNode focusNode;

  PdfPreview({Key? key, required this.focusNode, this.pdfUrl, this.pdfHeight})
      : super(key: key);

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  List<File> _selectedImages = [];
  File? _pdfFile;
  bool _showPdf = true;
  double containerHeight = 0;

  // deleting the pdf
  void _deletePdf() async {
    setState(() {
      _showPdf = false;
    });
    //delete the file if it is not null & reset the images
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
      //else set the pdf file to null
    } else {
      setState(() {
        widget.pdfUrl = null;
      });
    }
  }

// take/select the image & generate the pdf & show it
  void _addPdf(String? variant) async {
    if (variant == "gallery") {
      await _pickImages();
    } else if (variant == "camera") {
      await _takeImages();
    }

    await _generatePdf();
    setState(() {
      _showPdf = true;
    });
  }

  //select the images from the gallery
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles == null) return;

    setState(() {
      _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  //take one image with the camera
  Future<void> _takeImages() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() {
      _selectedImages = [File(pickedFile.path)];
    });
  }

  //reset the images
  void _resetImages() {
    setState(() {
      _selectedImages = [];
    });
  }

  //generate the pdf
  Future<void> _generatePdf() async {
    final doc = pdf.Document();

    for (final image in _selectedImages) {
      final img = pdf.MemoryImage(image.readAsBytesSync());
      doc.addPage(pdf.Page(
        build: (context) => pdf.Center(child: pdf.Image(img)),
      ));
    }

    final output = await getTemporaryDirectory();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}.pdf';
    final file = File('${output.path}/$fileName');
    final bytes = await doc.save();
    await file.writeAsBytes(bytes);

    setState(() {
      _pdfFile = file;
    });

    getPDFSize(_pdfFile!.path);
    PdfFile.setName(fileName);
    PdfFile.setPath(_pdfFile!.path);
  }

  //get the pdf-size
  Future<void> getPDFSize(String path) async {
    final file = File(path);
    final document = await PdfDocument.openFile(file.path);
    //get the first page (starts with 1 not with 0) and from there the height
    final page = await document.getPage(1);
    double height = page.height;
    int pageCount = document.pageCount;
    setState(() {
      containerHeight = (height * pageCount);
    });
    await document.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_pdfFile != null || widget.pdfUrl != null) && _showPdf
        ? Focus(
            focusNode: widget.focusNode,
            child: Container(
              height: 450,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Values.cardRadius),
                border: Border.all(color: AppColor.blueActive, width: 2),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Values.cardRadius - 4),
                    child: SingleChildScrollView(
                      child: Container(
                        height: (widget.pdfHeight != null)
                            ? widget.pdfHeight!.ceilToDouble()
                            : containerHeight,
                        child: InteractiveViewer(
                          clipBehavior: Clip.none,
                          constrained: true,
                          child: PDF(
                            enableSwipe: true,
                            swipeHorizontal: false,
                            autoSpacing: true,
                            pageFling: false,
                            fitEachPage: false,
                            onError: (error) {
                              print(error.toString());
                            },
                            onPageError: (page, error) {
                              print('$page: ${error.toString()}');
                            },
                          ).fromPath(widget.pdfUrl ?? _pdfFile!.path),
                        ), //.fromAsset(_pdfFile!.path),
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

class PdfFile {
  static String? _filename;
  static String? _filePath;

  static void setName(String name) {
    _filename = name;
  }

  static String? getName() => _filename;

  static void setPath(String path) {
    _filePath = path;
  }

  static String? getPath() => _filePath;
}
