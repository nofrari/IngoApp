import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/models/account.dart';
import 'package:flutter/material.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/accounts/account_item.dart';
import 'package:frontend/widgets/button.dart';
import 'package:provider/provider.dart';

import '../../services/accounts_service.dart';

class AccountsOverview extends StatefulWidget {
  const AccountsOverview({required this.accounts, super.key});

  final List<Account> accounts;

  @override
  State<AccountsOverview> createState() => _AccountsOverviewState();
}

class _AccountsOverviewState extends State<AccountsOverview> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
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
                .map((account) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Start(
                              pageId: 3,
                              accountId: account.id,
                            ),
                          ),
                        );
                      },
                      child: AccountItem(
                        account: account,
                      ),
                    ))
                .toList(),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10,
              ),
              child: Button(
                btnText: "ZUR KONTOÜBERSICHT",
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Start(
                        pageId: 1,
                      ),
                    ),
                  );
                },
                theme: ButtonColorTheme.secondaryLight,
              ),
            )
          ],
        ),
      ),
    );
  }
}
