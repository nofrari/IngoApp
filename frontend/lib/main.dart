import 'package:flutter/material.dart';
import 'package:frontend/services/manualentry_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/services/scanner_service.dart';
import 'start.dart';

final ImageCache testImageCache = ImageCache();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScannerService.init();
  await ManualEntryService.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (BuildContext context) => ScannerService(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => ManualEntryService(),
      ),
    ],
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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('de'),
          Locale('en')
        ],
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Start());
    //home: const Start());
  }
}
