import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/models/account.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/accounts/account_item.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/transactions/transaction_item.dart';

class AccountsOverview extends StatefulWidget {
  const AccountsOverview({required this.accounts, super.key});

  final List<Account> accounts;

  @override
  State<AccountsOverview> createState() => _AccountsOverviewState();
}

class _AccountsOverviewState extends State<AccountsOverview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.neutral500,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 15),
            width: double.infinity,
            child: Text(
              "KONTENÜBERSICHT",
              style: Fonts.textHeadingBold,
            ),
          ),
          ...widget.accounts
              .map((account) => AccountItem(
                    account: account,
                  ))
              .toList(),
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 10,
            ),
            child: Button(
              btnText: "ZUR KONTOÜBERSICHT",
              onTap: () {},
              theme: ButtonColorTheme.secondaryLight,
            ),
          )
        ],
      ),
    );
  }
}
