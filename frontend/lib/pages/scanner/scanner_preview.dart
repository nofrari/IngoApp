import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/services/scanner_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:frontend/widgets/scanner/tiny_preview.dart';
import 'package:provider/provider.dart';
import 'dart:io';

//import constants
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/values.dart';
import 'scanner_camera.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class ScannerPreview extends StatefulWidget {
  const ScannerPreview({super.key});

  @override
  State<ScannerPreview> createState() => _ScannerPreviewState();
}

class _ScannerPreviewState extends State<ScannerPreview>
    with WidgetsBindingObserver {
  final ScrollController _controller = ScrollController();

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
      final directory = await getTemporaryDirectory();
      final cacheDir = directory.path;
      final cacheDirFile = Directory(cacheDir);
      await cacheDirFile.delete(recursive: true);
    }

    return Scaffold(
      appBar: Header(
        onTap: () async {
          await clearCache();
          Navigator.pop(context);
        },
        element: SizedBox(
          height: 50,
          // horizontal list of preview images with length of the list of images in the cache
          child: ListView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: ((context, index) {
              // state variable selectedImage is set to the image that is tapped
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedImage = images.elementAt(index);
                  });
                  debugPrint('Selcted Image: $selectedImage');
                },
                child: TinyPreview(
                  selectedImage: selectedImage!,
                  images: images,
                  index: index,
                ),
              );
            }),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                selectedImage != null
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Values.cardRadius),
                          border:
                              Border.all(color: AppColor.blueLight, width: 4),
                        ),
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Values.cardRadius - 4),
                            child: Image.file(File(selectedImage!))),
                      )
                    : const Center(
                        child: Text("No Images"),
                      ),
// redo button
                Positioned(
                  top: 5,
                  left: 1,
                  child: RoundButton(
                    icon: Icons.redo,
                    onTap: () async {
                      if (context.mounted) {
                        context
                            .read<ScannerService>()
                            .rememberPosition(images.indexOf(selectedImage!));
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
// delete button
                Positioned(
                  top: 5,
                  right: 1,
                  child: RoundButton(
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
                        _controller
                            .jumpTo(_controller.position.maxScrollExtent);
                      } else if (images.isEmpty) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                // add button
                Positioned(
                  bottom: 5,
                  child: RoundButton(
                    icon: Icons.add,
                    onTap: () async {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 45,
            ),
            child: Button(
                btnText: "BESTÄTIGEN",
                onTap: () async {
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
      backgroundColor: AppColor.background,
    );
  }
}
