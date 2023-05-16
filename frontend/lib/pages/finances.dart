import 'package:flutter/material.dart';
import 'package:frontend/models/color.dart';
import 'package:frontend/models/icon.dart';

import 'package:frontend/widgets/transactions/transaction_list.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../services/initial_service.dart';
import '../services/transaction_service.dart';

class Finances extends StatefulWidget {
  const Finances({super.key});

  @override
  State<Finances> createState() => _FinancesState();
}

class _FinancesState extends State<Finances> {
  List<TransactionModel> transactions = [];
  List<ColorModel> colors = [];
  List<IconModel> icons = [];
  @override
  Widget build(BuildContext context) {
    transactions = context.watch<TransactionService>().getTransactions();
    colors = context.watch<InitialService>().getColors();
    icons = context.watch<InitialService>().getIcons();
    debugPrint("${transactions.toList().toString()}");
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TransactionList(
        transactions: transactions,
      ),
    );
  }
}
