import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/account.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/transactions/transaction_item.dart';

class AccountItem extends StatefulWidget {
  const AccountItem({required this.account, super.key});
  final Account account;
  @override
  State<AccountItem> createState() => _AccountItemState();
}

class _AccountItemState extends State<AccountItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: AppColor.neutral700),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.account.name, style: Fonts.textTransactionName),
            Text(
              widget.account.formatedAmount(widget.account.amount),
              style: Fonts.textHeadingBold,
            ),
          ],
        ),
      ),
    );
  }
}
