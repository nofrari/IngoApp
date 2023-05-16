import 'package:flutter/material.dart';

import '../constants/fonts.dart';
import '../constants/values.dart';

class DataProtection extends StatefulWidget {
  const DataProtection({super.key});

  @override
  State<DataProtection> createState() => _DataProtectionState();
}

class _DataProtectionState extends State<DataProtection> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        padding: Values.bigCardPadding,
        child: Text('Datenschutz-Text kommt hier her', style: Fonts.text200));
  }
}
