import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'start.dart';
import 'package:provider/provider.dart';
import 'pages/manual-entry.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(Provider(
    create: (BuildContext context) {},
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        home: const ManualEntry());
    //home: const Start());
  }
}
