import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/widgets/accounts/account_card.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:provider/provider.dart';

import '../../models/account.dart';

class Accounts extends StatefulWidget {
  Accounts({super.key, this.onFocusChanged});

  final ValueChanged<bool>? onFocusChanged;

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  bool _canAddCard = true;

  List<Account> accounts = [];

  void addCard() async {
    if (_canAddCard) {
      await context
          .read<AccountsService>()
          .setAccount(id: "new", heading: "", balance: 0);

      setState(() {
        accounts = context.read<AccountsService>().getAccounts();
      });

      debugPrint("Accounts: ${accounts.length}");
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      accounts = context.watch<AccountsService>().getAccounts();
    });
    for (var account in accounts) {
      if (account.id == "new") {
        debugPrint("found new item");
        setState(() {
          _canAddCard = false;
        });
        break;
      }
      //for breakes before set to true when found new item
      setState(() {
        _canAddCard = true;
      });
    }
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
                  child: Text(Strings.accountsHeading,
                      style: Fonts.textHeadingBold),
                ),
                Expanded(
                  child: ListView.builder(
                    padding:
                        EdgeInsets.only(bottom: accounts.length >= 3 ? 100 : 0),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      return AccountCard(
                          onFocusChanged: (value) {
                            widget.onFocusChanged!(value);
                          },
                          ableToDelete: accounts.length > 1,
                          isEditable: _canAddCard != false,
                          accountId: accounts[index].id,
                          initialHeading: accounts[index].name,
                          initialBalance: accounts[index].amount,
                          deleteCallback: () async {
                            debugPrint("delete callback");
                            setState(() {
                              accounts =
                                  context.read<AccountsService>().getAccounts();
                            });
                            for (var account in accounts) {
                              debugPrint("callback account: ${account.name}");
                              debugPrint(
                                  "callback account amount: ${account.amount}");
                            }
                          },
                          doneCallback: () {
                            debugPrint("done callback");
                            setState(() {
                              _canAddCard = true;
                              accounts =
                                  context.read<AccountsService>().getAccounts();
                            });
                          }
                          //add delete callback to reassign accounts list
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
          accounts.length > 3
              ? ButtonTransparentContainer(
                  child: Container(
                    margin: Values.buttonPadding,
                    child: Button(
                      isTransparent: true,
                      btnText: Strings.accountsButton,
                      onTap: addCard,
                      theme: _canAddCard
                          ? ButtonColorTheme.secondaryDark
                          : ButtonColorTheme.disabled,
                    ),
                  ),
                )
              : Container(
                  margin: Values.buttonPadding,
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Button(
                    isTransparent: false,
                    btnText: Strings.accountsButton,
                    onTap: addCard,
                    theme: _canAddCard
                        ? ButtonColorTheme.secondaryDark
                        : ButtonColorTheme.disabled,
                  ),
                ),
        ],
      ),
    );
  }
}
