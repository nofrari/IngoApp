import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/services/scanner_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/header.dart';
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
    if (selectedImage == null && images.isNotEmpty) {
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
