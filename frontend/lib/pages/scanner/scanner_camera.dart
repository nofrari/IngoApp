import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/manual_entry.dart';
import 'package:frontend/services/custom_cache_manager.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/popup.dart';
import 'package:frontend/widgets/text_google.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:frontend/pages/scanner/scanner_preview.dart';
import 'package:frontend/services/scanner_service.dart';
import 'package:provider/provider.dart';

class ScannerCamera extends StatefulWidget {
  const ScannerCamera({super.key});

  @override
  State<ScannerCamera> createState() => _ScannerCameraState();
}

// Uses WidgetsBindingObserver to detect when the app is in the background, to stop the camera.
class _ScannerCameraState extends State<ScannerCamera>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  File? imageFile;
  bool _isPermissionGranted = false;

  late final Future<void> _future;
  CameraController? _cameraController;
  int? position;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    super.dispose();
  }

  //As stated above, this method is called when the app is in the background and will stop the camera.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = context.watch<ScannerService>().getImages();
    position = context.watch<ScannerService>().getPosition();
    debugPrint("Position: $position, Images: ${images.isNotEmpty}");

    String headerText() {
      if (position != null) {
        return "WIEDERHOLEN";
      } else if (images.isNotEmpty) {
        return "HINZUFÜGEN";
      } else {
        return "SCANNER";
      }
    }

    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: Header(
              onTap: () async {
                if (images.isNotEmpty) {
                  // warning dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => PopUp(
                      content:
                          "Wenn du den Scanner verlässt, werden alle gescannten Bilder gelöscht. Bist du sicher, dass du den Scanner verlassen möchtest?",
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
                                        builder: (context) => Start(),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Start(),
                    ),
                  );
                }
              },
              element: TextGoogle(
                style: Fonts.text400,
                text: headerText(),
                align: TextAlign.center,
              ),
            ),
            backgroundColor: _isPermissionGranted ? Colors.transparent : null,
            body: _isPermissionGranted
                ? Container(
                    padding: Values.paddingHorizontal,
                    color: AppColor.backgroundFullScreen,
                    child: SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Values.cardRadius),
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: AppColor.blueActive,
                                      width: 4,
                                    ),
                                  ),
                                  child: FutureBuilder<List<CameraDescription>>(
                                    future: availableCameras(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        _initCameraController(snapshot.data!);
                                        return Container(
                                          width: double.infinity,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                Values.cardRadius - 4),
                                            child: CameraPreview(
                                                _cameraController!),
                                          ),
                                        );
                                      } else {
                                        return const LinearProgressIndicator();
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  margin: Values.buttonPadding,
                                  child: Button(
                                    btnText: (images.isEmpty || position == 0)
                                        ? "SCANNEN"
                                        : "AUFNEHMEN",
                                    onTap: _scanImage,
                                    theme: ButtonColorTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: Values.buttonPadding,
                            child: Button(
                              btnText: (position == null && images.isEmpty)
                                  ? "MANUELLE EINGABE"
                                  : "ABBRECHEN",
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        (position == null && images.isEmpty)
                                            ? ManualEntry()
                                            : const ScannerPreview(),
                                  ),
                                );
                              },
                              theme: ButtonColorTheme.secondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Container(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                      child: const Text(
                        'Camera permission denied',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          );
        });
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;
    debugPrint("scanImage");

    try {
      final pictureFile = await _cameraController!.takePicture();

//position is used for the redo button in preview and if its not null, then the redo button was pressed, otherwise just normal scan
      if (context.mounted) {
        if (position != null) {
          context
              .read<ScannerService>()
              .setImage(path: pictureFile.path, position: position);
        } else {
          context.read<ScannerService>().setImage(path: pictureFile.path);
        }
      }
      debugPrint(pictureFile.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('An error occurred when scanning text'),
        ),
      );
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ScannerPreview(),
        ),
      );
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
