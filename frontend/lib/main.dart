import 'package:flutter/material.dart';
import 'start.dart';
import 'package:provider/provider.dart';

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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Start(),
    );
  }
}
