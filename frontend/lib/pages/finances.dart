import 'package:flutter/material.dart';

class Finances extends StatefulWidget {
  const Finances({super.key});

  @override
  State<Finances> createState() => _FinancesState();
}

class _FinancesState extends State<Finances> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Finances Screen'),
      ),
    );
  }
}
