import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/services/scanner_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/header.dart';
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
  @override
  void initState() {
    super.initState();
  }

  Future<void> clearCache() async {
    await DefaultCacheManager().emptyCache();
    final directory = await getTemporaryDirectory();
    final cacheDir = directory.path;
    final cacheDirFile = Directory(cacheDir);
    await cacheDirFile.delete(recursive: true);
  }

  String? selectedImage;
  @override
  Widget build(BuildContext context) {
    List<String> images = context.watch<ScannerService>().getImages();
    if (selectedImage == null && images.isNotEmpty) {
      selectedImage = images.last;
    }
    return Scaffold(
      appBar: Header(
        onTap: () {
          Navigator.pop(context);
        },
        element: Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 50,
          // horizontal list of preview images with length of the list of images in the cache
          child: ListView.builder(
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
                // if the image is selected, a border is added to the image
                child: Container(
                  decoration: (selectedImage == images.elementAt(index))
                      ? BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Values.cardRadius - 15),
                          border: Border.all(color: AppColor.blueLight),
                        )
                      : null,
                  width: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Values.cardRadius - 15),
                    child: Image.file(File(images.elementAt(index)),
                        fit: BoxFit.cover),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      // AppBar(
      //   elevation: 0,
      //   leading: GestureDetector(
      //     onTap: () {}, // Image tapped
      //     child: BackButton(
      //       color: AppColor.neutral100,
      //     ),
      //   ),
      //   leadingWidth: Values.leadingWidth,
      //   actions: [
      //     SizedBox(
      //       width: Values.actionsWidth,
      //       child: ElevatedButton(
      //         onPressed: () {},
      //         style: ElevatedButton.styleFrom(
      //             shape: const CircleBorder(),
      //             backgroundColor: AppColor.blueLight),
      //         child: const Text("AH"),
      //       ),
      //     ),
      //   ],
      //   backgroundColor: AppColor.background,
      // ),
      body: Column(
        children: [
          Expanded(
            child: selectedImage != null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Values.cardRadius),
                      border: Border.all(color: AppColor.blueLight, width: 4),
                    ),
                    child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Values.cardRadius - 4),
                        child: Image.file(File(selectedImage!))),
                  )
                : const Center(
                    child: Text("No Images"),
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
                  if (context.mounted) {
                    context.read<ScannerService>().clearImages();
                  }
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.neutral100,
        onPressed: () async {
          debugPrint(images.length.toString());
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScannerCamera(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: AppColor.neutral600,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
