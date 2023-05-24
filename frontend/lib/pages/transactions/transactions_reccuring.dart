import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/models/interval.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/pages/manual_entry.dart';
import 'package:frontend/pages/transactions/transactions_list_per_type.dart';
import 'package:frontend/services/initial_service.dart';
import 'package:frontend/services/transaction_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/header.dart';
import 'package:provider/provider.dart';
import '../../constants/values.dart';

class ReccuringTransactions extends StatefulWidget {
  const ReccuringTransactions({super.key});

  @override
  State<ReccuringTransactions> createState() => _ReccuringTransactionsState();
}

class _ReccuringTransactionsState extends State<ReccuringTransactions> {
  List<TransactionModel> transactions = [];
  List<IntervalModel> intervals = [];

  @override
  Widget build(BuildContext context) {
    setState(() {
      transactions = context.watch<TransactionService>().getTransactions();
      intervals = context.watch<InitialService>().getInterval();
      intervals.removeAt(0);
    });
    return Scaffold(
      appBar: Header(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Start(pageId: 4),
            ),
          );
        },
        element: Text(
          Strings.transactionsReccuringHeading,
          style: Fonts.textHeadingBold,
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: AppColor.backgroundFullScreen,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Container(
                margin: Values.bigCardMargin,
                child: Column(
                  children: [
                    Column(
                      children: <Widget>[
                        ...intervals
                            .map((intervalData) => TransactionsTypeListItem(
                                transactions: transactions,
                                interval: intervalData))
                            .toList(),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          ButtonTransparentContainer(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Button(
                  isTransparent: true,
                  btnText: Strings.transactionsAdd.toUpperCase(),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManualEntry(),
                      ),
                    );
                  },
                  theme: ButtonColorTheme.secondaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
