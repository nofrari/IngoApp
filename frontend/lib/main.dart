import 'package:flutter/material.dart';
import 'package:frontend/pages/scanner/scanner_preview.dart';
import 'package:frontend/services/scanner_service.dart';
import 'start.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final ImageCache testImageCache = ImageCache();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScannerService.init();
  runApp(ChangeNotifierProvider(
    create: (BuildContext context) => ScannerService(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addObserver(this);
  // }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.detached) {
  //     debugPrint("app stopped");
  //     clearCache();
  //   }
  // }

  // Future<void> clearCache() async {
  //   await DefaultCacheManager().emptyCache();
  //   final directory = await getTemporaryDirectory();
  //   final cacheDir = directory.path;
  //   final cacheDirFile = Directory(cacheDir);
  //   await cacheDirFile.delete(recursive: true);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Start(),
    );
  }
}
