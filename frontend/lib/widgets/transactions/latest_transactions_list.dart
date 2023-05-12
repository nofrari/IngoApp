import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/transactions/transaction_item.dart';

class LatestTransactionList extends StatefulWidget {
  const LatestTransactionList({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  State<LatestTransactionList> createState() => _LatestTransactionListState();
}

class _LatestTransactionListState extends State<LatestTransactionList> {
  @override
  Widget build(BuildContext context) {
    //for long lists use ListView
    return Container(
      color: AppColor.neutral500,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 15),
            width: double.infinity,
            child: Text(
              "LETZTE TRANSAKTIONEN",
              style: Fonts.textHeadingBold,
            ),
          ),
          ...widget.transactions
              .map((transaction) => TransactionItem(
                    transaction: transaction,
                  ))
              .toList(),
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 10,
            ),
            child: Button(
              btnText: "MEHR ANZEIGEN",
              onTap: () {},
              theme: ButtonColorTheme.secondaryLight,
            ),
          )
        ],
      ),
    );
  }
}
