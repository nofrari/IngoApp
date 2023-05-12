import 'package:flutter/material.dart';
import 'package:frontend/services/initial_service.dart';
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
  await InitialService.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (BuildContext context) => ScannerService(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => ManualEntryService(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => InitialService(),
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
  }
}
