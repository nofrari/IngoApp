import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/services/initial_service.dart';
import 'package:frontend/services/manualentry_service.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/services/transaction_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/services/scanner_service.dart';
import 'pages/userauth.dart';

final ImageCache testImageCache = ImageCache();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScannerService.init();
  await ManualEntryService.init();
  await AccountsService.init();
  await InitialService.init();
  await ProfileService.init();
  await TransactionService.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (BuildContext context) => ScannerService(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => ManualEntryService(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => AccountsService(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => InitialService(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => ProfileService(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => TransactionService(),
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
    User user = context.read<ProfileService>().getUser();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('de'), Locale('en')],
        title: 'Ingo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: user.id == "" ? Auth() : Start());
  }
}
