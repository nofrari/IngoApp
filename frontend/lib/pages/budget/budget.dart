import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/budget/budget_add.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/widgets/accounts/account_card.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:provider/provider.dart';

import '../../../models/account.dart';
import '../../widgets/budget/budget_card.dart';

class Budget extends StatefulWidget {
  const Budget({super.key});

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  List<Widget> budgetCards = [
    // const AccountCard(
    //   accountId: "1",
    //   initialHeading: "Geldbörse",
    //   initialBalance: 1000,
    // ),
    // const AccountCard(
    //   accountId: "2",
    //   initialHeading: "Bankomat",
    //   initialBalance: 800,
    // ),
  ];

  //umändern auf budgets
  List<Account> accounts = [];

  @override
  Widget build(BuildContext context) {
    setState(() {
      accounts = context.watch<AccountsService>().getAccounts();
    });

    return Scaffold(
      backgroundColor: AppColor.backgroundFullScreen,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: Values.accountHeading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    Strings.budgetHeading,
                    style: Fonts.textHeadingBold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      //return cards[index];
                      return BudgetCard(
                          name: "Name",
                          startDate: DateTime.now(),
                          endDate: DateTime.now(),
                          categories: [],
                          limit: 500.30,
                          currAmount: 10);
                    },
                  ),
                ),
              ],
            ),
          ),
          ButtonTransparentContainer(
            child: Container(
              margin: Values.buttonPadding,
              child: Button(
                  isTransparent: true,
                  btnText: Strings.budgetButton,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BudgetAdd(),
                      ),
                    );
                  },
                  theme: ButtonColorTheme.secondaryDark),
            ),
          )
        ],
      ),
    );
  }
}
