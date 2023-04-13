import 'package:flutter/material.dart';
import 'package:frontend/models/transaction.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2, color: AppColor.neutral600),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: 80,
              ),
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: AppColor.blueLight,
                    padding: const EdgeInsets.all(15)),
                child: Text(transaction.category,
                    style: TextStyle(color: AppColor.neutral100)),
              ),
            ),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.formattedDate,
                      style: Fonts.textDateSmall,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Text(
                          transaction.name,
                          style: Fonts.textTransactionName,
                        ),
                        Text(" - ", style: Fonts.textTransactionDescription),
                        Text(
                          transaction.name,
                          style: Fonts.textTransactionDescription,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
              child: Text(
                '${transaction.amount.toStringAsFixed(2)} €',
                style: Fonts.textHeadingBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
