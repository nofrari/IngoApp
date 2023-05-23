import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/models/interval.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/models/transaction_type.dart';
import 'package:frontend/widgets/transactions/transaction_item.dart';

class TransactionsTypeListItem extends StatelessWidget {
  TransactionsTypeListItem(
      {required this.transactions, required this.interval, super.key});
  List<TransactionModel> transactions;
  IntervalModel interval;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              interval.name.toUpperCase(),
              style: Fonts.textHeadingBold,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return (transactions[index].interval_id == interval.interval_id)
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 5),
                      decoration: BoxDecoration(
                          border: const Border.fromBorderSide(BorderSide.none),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColor.neutral700),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: TransactionItem(
                            transaction: transactions[index], isSmall: true),
                      ),
                    )
                  : Container();
            },
          )
        ],
      ),
    );
  }
}
