import 'package:flutter/material.dart';
import 'package:frontend/models/transaction.dart';
import '../../constants/colors.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 2, color: AppColor.neutral600),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                transaction.category,
                style: TextStyle(color: AppColor.neutral100),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.formattedDate,
                  style: TextStyle(color: AppColor.neutral100, fontSize: 12),
                ),
                Text(
                  transaction.name,
                  style: TextStyle(color: AppColor.neutral100),
                )
              ],
            ),
            Container(
              child: Text(
                '${transaction.amount.toStringAsFixed(2)} €',
                style: TextStyle(
                    color: AppColor.neutral100, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
