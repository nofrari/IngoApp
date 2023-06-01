import 'package:flutter/material.dart';
import 'package:frontend/pages/manual_entry.dart';
import 'package:frontend/services/custom_cache_manager.dart';
import 'package:frontend/services/manualentry_service.dart';
import 'package:frontend/services/scanner_service.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/popup.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:frontend/widgets/scanner/tiny_preview.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';

//import constants
import '../../constants/colors.dart';
import '../../constants/values.dart';
import 'scanner_camera.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';

class ScannerPreview extends StatefulWidget {
  const ScannerPreview({super.key});

  @override
  State<ScannerPreview> createState() => _ScannerPreviewState();
}

class _ScannerPreviewState extends State<ScannerPreview>
    with WidgetsBindingObserver {
  final ScrollController _controller = ScrollController();

  Dio dio = Dio();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    //if list is so long it extends past the screen, scoll to the last position
    //addPostFrameCallback is basically onLoad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  String? selectedImage;
  @override
  Widget build(BuildContext context) {
    List<String> images = context.watch<ScannerService>().getImages();
    //position used for redoing a scan
    int? position = context.read<ScannerService>().getPosition();

    if (position != null) {
      selectedImage = images.elementAt(position);
      context.read<ScannerService>().forgetPosition();
    } else if (selectedImage == null && images.isNotEmpty) {
      selectedImage = images.last;
    }

    Future<void> sendImages() async {
      setState(() {
        _isLoading = true;
      });
      var formData = FormData();

      for (var i = 0; i < images.length; i++) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(images[i]),
        ));
      }
      var response = await dio.post("${Values.serverURL}/scanner/upload",
          data: formData, options: Options(responseType: ResponseType.json));
      debugPrint(response.toString());
      //process pdf data from response
      final pdfData = base64Decode(response.data['pdf']);
      final pdfName = response.data['pdf_name'] + '.pdf';
      //get path to pdf
      final pdfFile = await DefaultCacheManager()
          .putFile(pdfName, pdfData, fileExtension: 'pdf');
      final cacheDir = await DefaultCacheManager().getFileFromCache(pdfName);
      final pdfPath = '${cacheDir!.file.dirname}/${cacheDir.file.basename}';

      final amount = double.tryParse(response.data['total_amount'].toString());
      final height = int.tryParse(response.data['pdf_height'].toString());

      if (height == null) throw Error();
      //create manual entry
      if (context.mounted) {
        context.read<ManualEntryService>().setManualEntry(
            pdfName,
            pdfPath,
            height,
            response.data['supplier_name'],
            amount,
            response.data['date'],
            response.data['category']);
      }
      debugPrint(pdfPath);
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          Scaffold(
            appBar: Header(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => PopUp(
                    content:
                        "Wenn du die Preview verlässt, werden alle gescannten Bilder gelöscht. Bist du sicher, dass du zurück zum Scanner möchtest?",
                    actions: [
                      Container(
                        margin: Values.buttonPadding,
                        child: Column(
                          children: [
                            Button(
                                btnText: "ABBRECHEN",
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                theme: ButtonColorTheme.secondaryLight),
                            Button(
                                btnText: "FORTFAHREN",
                                onTap: () async {
                                  if (context.mounted) {
                                    try {
                                      await CustomCacheManager.clearCache(
                                          context, images);
                                    } catch (e) {
                                      debugPrint(e.toString());
                                    }
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ScannerCamera(),
                                    ),
                                  );
                                },
                                theme: ButtonColorTheme.primary),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
              element: SizedBox(
                height: 50,
                // horizontal list of preview images with length of the list of images in the cache
                //Couldn't use Listview because it couldn't center the items
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _controller,
                  child: Row(
                    children: [
                      for (var image in images)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = image;
                            });
                            debugPrint('Selected Image: $selectedImage');
                          },
                          child: TinyPreview(
                            selectedImage: selectedImage!,
                            images: images,
                            index: images.indexOf(image),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            body: Container(
              padding: Values.paddingHorizontal,
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          selectedImage != null
                              ? Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Values.cardRadius),
                                    border: Border.all(
                                        color: AppColor.blueActive, width: 4),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          Values.cardRadius - 4),
                                      child: Image.file(File(selectedImage!),
                                          fit: BoxFit.cover)),
                                )
                              : const Center(
                                  child: Text("No Images"),
                                ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // redo button
                                    RoundButton(
                                      icon: Icons.redo,
                                      onTap: () async {
                                        if (context.mounted) {
                                          context
                                              .read<ScannerService>()
                                              .rememberPosition(images
                                                  .indexOf(selectedImage!));
                                        }
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ScannerCamera(),
                                          ),
                                        );
                                      },
                                    ),
                                    //delete button
                                    RoundButton(
                                      icon: Icons.delete,
                                      onTap: () async {
                                        if (context.mounted) {
                                          context
                                              .read<ScannerService>()
                                              .forgetPosition();
                                          context
                                              .read<ScannerService>()
                                              .deleteImage(selectedImage!);
                                          images = context
                                              .read<ScannerService>()
                                              .getImages(); // Hier aktualisieren Sie die `images`-Liste
                                          selectedImage = images.isNotEmpty
                                              ? images.last
                                              : null; // Hier aktualisieren Sie die `selectedImage`-Variable
                                        }

                                        setState(() {
                                          if (images.isNotEmpty) {
                                            selectedImage = images.last;
                                          } else {
                                            selectedImage = null;
                                          }
                                        });

                                        if (images.isNotEmpty) {
                                          _controller.jumpTo(_controller
                                              .position.maxScrollExtent);
                                        } else if (images.isEmpty) {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ScannerCamera(),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // add button
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: RoundButton(
                                    icon: Icons.add,
                                    onTap: () {
                                      if (images.length == 1) {
                                        // warning dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              PopUp(
                                            content:
                                                "Vom Scanner wird nur der erste Scan auf Werte geprüft. Es kann vorkommen, dass die Einträge manuell überarbeitet werden müssen.",
                                            actions: [
                                              Container(
                                                margin: Values.buttonPadding,
                                                child: Column(
                                                  children: [
                                                    Button(
                                                        btnText: "ABBRECHEN",
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        theme: ButtonColorTheme
                                                            .secondaryLight),
                                                    Button(
                                                        btnText: "FORTFAHREN",
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const ScannerCamera(),
                                                            ),
                                                          );
                                                        },
                                                        theme: ButtonColorTheme
                                                            .primary),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                //not done yet
                                                const ScannerCamera(),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          if (_isLoading)
                            const Opacity(
                              opacity: 0.8,
                              child: ModalBarrier(
                                  dismissible: false, color: Colors.black),
                            ),
                          if (_isLoading)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      margin: Values.buttonPadding,
                      child: Button(
                          btnText: "BESTÄTIGEN",
                          onTap: () async {
                            try {
                              await sendImages().then((value) {
                                setState(() {
                                  _isLoading = true;
                                });
                              });
                            } catch (e) {
                              debugPrint(e.toString());
                            }

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManualEntry(),
                              ),
                            );
                          },
                          theme: ButtonColorTheme.primary),
                    )
                  ],
                ),
              ),
            ),
            backgroundColor: AppColor.backgroundFullScreen,
          ),
        ],
      ),
    );
  }
}
