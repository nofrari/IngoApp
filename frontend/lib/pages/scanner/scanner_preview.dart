import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/services/scanner_service.dart';
import 'package:frontend/start.dart';
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
import '../../constants/strings.dart';
import '../../constants/values.dart';
import 'scanner_camera.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:typed_data';

class ScannerPreview extends StatefulWidget {
  const ScannerPreview({super.key});

  @override
  State<ScannerPreview> createState() => _ScannerPreviewState();
}

class _ScannerPreviewState extends State<ScannerPreview>
    with WidgetsBindingObserver {
  final ScrollController _controller = ScrollController();

  Dio dio = Dio();

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

    Future<void> clearCache() async {
      if (context.mounted) {
        context.read<ScannerService>().clearImages();
      }
      await DefaultCacheManager().emptyCache();
      try {
        final directory = await getTemporaryDirectory();
        final cacheDir = directory.path;
        final cacheDirFile = Directory(cacheDir);
        await cacheDirFile.delete(recursive: true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred when deleting cache'),
          ),
        );
      }
    }

    Future<void> sendImages() async {
      var formData = FormData();

      for (var i = 0; i < images.length; i++) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(images[i]),
        ));
      }
      var response = await dio.post("http://10.0.2.2:5432/scanner/upload",
          //var response = await dio.post("https://data.ingoapp.at/scanner/upload",
          data: formData,
          options: Options(responseType: ResponseType.json));
      debugPrint(response.toString());
      final pdfFile = await DefaultCacheManager().putFile(
          response.data['pdf_name'], base64Decode(response.data['pdf']));
      final isDa = await pdfFile.exists();
      debugPrint(isDa.toString());
    }

    return Scaffold(
      appBar: Header(
        onTap: () async {
          try {
            await clearCache();
          } catch (e) {
            debugPrint(e.toString());
          }
          Navigator.pop(context);
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
                              borderRadius:
                                  BorderRadius.circular(Values.cardRadius),
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
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // redo button
                              RoundButton(
                                icon: Icons.redo,
                                onTap: () async {
                                  if (context.mounted) {
                                    context
                                        .read<ScannerService>()
                                        .rememberPosition(
                                            images.indexOf(selectedImage!));
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                              RoundButton(
                                icon: Icons.delete,
                                onTap: () {
                                  debugPrint("Length1: ${images.length}");
                                  if (context.mounted) {
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
                                  debugPrint("Length2: ${images.length}");

                                  setState(() {
                                    if (images.isNotEmpty) {
                                      selectedImage = images.last;
                                    } else {
                                      selectedImage = null;
                                    }
                                  });

                                  if (images.isNotEmpty) {
                                    _controller.jumpTo(
                                        _controller.position.maxScrollExtent);
                                  } else if (images.isEmpty) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // add button
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: RoundButton(
                          icon: Icons.add,
                          onTap: () {
                            if (images.length == 1) {
                              // warning dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => PopUp(
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
                                                Navigator.pop(context);
                                              },
                                              theme:
                                                  ButtonColorTheme.secondary),
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
                                              theme: ButtonColorTheme.primary),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: Values.buttonPadding,
                child: Button(
                    btnText: "BESTÄTIGEN",
                    onTap: () async {
                      try {
                        await sendImages();
                      } catch (e) {
                        debugPrint(e.toString());
                      }

                      //TODO: add clear cache to end of manuelle eingabe
                      await clearCache();

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Start(),
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
    );
  }
}
