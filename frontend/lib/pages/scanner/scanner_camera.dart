import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/pages/profile.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/text_google.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
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

  Dio dio = Dio();

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
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          return Stack(
            children: [
              Scaffold(
                appBar: Header(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  element: TextGoogle(
                    style: Fonts.text400,
                    text: "SCANNER",
                    align: TextAlign.center,
                  ),
                ),
                backgroundColor:
                    _isPermissionGranted ? Colors.transparent : null,
                body: _isPermissionGranted
                    ? Container(
                        padding: Values.paddingHorizontal,
                        color: AppColor.background,
                        child: SafeArea(
                          child: Container(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Values.cardRadius),
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: AppColor.blueLight,
                                        width: 4,
                                      ),
                                    ),
                                    child:
                                        FutureBuilder<List<CameraDescription>>(
                                      future: availableCameras(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          _initCameraController(snapshot.data!);
                                          return Container(
                                            width: double.infinity,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 20),
                                        child: Button(
                                          btnText: "SCANNEN",
                                          onTap: _scanImage,
                                          theme: ButtonColorTheme.primary,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 20),
                                        child: Button(
                                          btnText: "MANUELLE EINGABE",
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    //not done yet
                                                    const Home(),
                                              ),
                                            );
                                          },
                                          theme: ButtonColorTheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Container(
                          padding:
                              const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: const Text(
                            'Camera permission denied',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ),
            ],
          );
        });
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;
    debugPrint("scanImage");
    try {
      final pictureFile = await _cameraController!.takePicture();

      if (context.mounted) {
        context.read<ScannerService>().setImage(pictureFile.path);
      }

      //not needed in the moment
      // if (pictureFile != null) {
      //   setState(() {
      //     imageFile = File(pictureFile.path);
      //   });
      // }
      debugPrint(pictureFile.path);
      var formData = FormData.fromMap(
        {
          "image": await MultipartFile.fromFile(pictureFile.path),
        },
      );
      //var response = await dio.post("http://10.0.2.2:5432/scanner/upload",
      var response = await dio.post("https://data.ingoapp.at/scanner/upload",
          data: formData);
      debugPrint(response.toString());
    } catch (e) {
      debugPrint("error2: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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

//obsolete, functionality is in _scanImage()
  Future _uploadImage() async {
    final navigator = Navigator.of(context);
    var formData = FormData.fromMap(
      {
        "image": await MultipartFile.fromFile(imageFile!.path),
      },
    );
    var response =
        await dio.post("http://10.0.2.2:5432/scanner/upload", data: formData);
    debugPrint(response.toString());
    // navigator.pop(context);
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
