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

import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class PdfPreview extends StatefulWidget {
  String? pdfUrl;
  int? pdfHeight;

  PdfPreview({Key? key, this.pdfUrl, this.pdfHeight}) : super(key: key);

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
      doc.addPage(
        pdf.Page(
          build: (context) => pdf.FullPage(
            child: pdf.FittedBox(
              child: pdf.Image(img),
              fit: pdf.BoxFit.cover,
            ),
            ignoreMargins: true,
          ),
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}.pdf';
    final file = File('${output.path}/$fileName');
    final bytes = await doc.save();
    await file.writeAsBytes(bytes);

    final height = await getPDFSize(file.path);
    setState(() {
      _pdfFile = file;
      containerHeight = height;
    });

    PdfFile.setName(fileName);
    PdfFile.setPath(_pdfFile!.path);
  }

  //get the pdf-size
  Future<double> getPDFSize(String path) async {
    final file = File(path);
    final document = await PdfDocument.openFile(file.path);

    double totalHeight = 0;
    double scalingFactor = 0.805; // Adjust this value to fine-tune the height

    for (int i = 0; i < document.pageCount; i++) {
      final page = await document.getPage(i + 1);
      double pageHeight = page.height;
      double pageWidth = page.width;

      // Adjust the container height based on the aspect ratio of the page
      double aspectRatio = pageWidth / pageHeight;
      double containerHeight = 450 / aspectRatio;

      totalHeight += containerHeight;
    }

    // Apply scaling factor to the total height
    totalHeight *= scalingFactor;

    await document.dispose();
    return totalHeight;
  }

  void getLoadedPDFSize() async {
    final double height = widget.pdfUrl != "" && widget.pdfUrl != null
        ? await getPDFSize(widget.pdfUrl!)
        : 0;
    setState(() {
      containerHeight = height;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    debugPrint("pdf preview pdfUrl: ${widget.pdfUrl}");
    getLoadedPDFSize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: (_pdfFile != null ||
                  (widget.pdfUrl != null && widget.pdfUrl != "")) &&
              _showPdf
          ? Focus(
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
                      borderRadius:
                          BorderRadius.circular(Values.cardRadius - 4),
                      child: SingleChildScrollView(
                        child: Container(
                          color: Colors.white,
                          height: (widget.pdfHeight != null)
                              ? widget.pdfHeight!.ceilToDouble()
                              : containerHeight,
                          child: InteractiveViewer(
                            clipBehavior: Clip.none,
                            constrained: true,
                            child: PdfViewer.openFile(
                              widget.pdfUrl ?? _pdfFile!.path,
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
                                            theme: ButtonColorTheme
                                                .secondaryLight),
                                        Button(
                                            btnText: "GALLERY",
                                            onTap: () {
                                              _addPdf("gallery");
                                              Navigator.pop(context);
                                            },
                                            theme: ButtonColorTheme
                                                .secondaryLight),
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
