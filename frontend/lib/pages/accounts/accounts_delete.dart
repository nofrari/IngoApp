import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/accounts/account_item.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/header.dart';
import 'package:provider/provider.dart';
import '../../models/account.dart';

class AccountsDelete extends StatefulWidget {
  const AccountsDelete(
      {super.key, required this.accountId, required this.deleteCallback});
  final String accountId;
  final void Function() deleteCallback;

  @override
  State<AccountsDelete> createState() => _AccountsDeleteState();
}

class _AccountsDeleteState extends State<AccountsDelete> {
  Dio dio = Dio();

  String selectedId = "";

  List<Account> accounts = [];

  void delete() async {
    if (selectedId == "") return;
    Map<String, dynamic> formData = {
      "old_account_id": widget.accountId,
      "new_account_id": selectedId,
    };

    await dio.post("${Values.serverURL}/transactions/change", data: formData);

    await dio.delete(
      "${Values.serverURL}/accounts/${widget.accountId}",
    );
    await context
        .read<AccountsService>()
        .deleteAccount(id: widget.accountId, newId: selectedId);
    widget.deleteCallback();
    //Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Start(
          pageId: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      accounts = context.watch<AccountsService>().getAccounts();
    });
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: Header(
          element: Text(
            Strings.accountsDelete,
            style: Fonts.textHeadingBold,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
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
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Center(
                        child: Text(
                          "Du bist dabei das Konto ${accounts.firstWhere((account) => account.id == widget.accountId).name} zu löschen. Bitte wähle, in welches Konto die Einträge des Kontos verschoben werden sollen.",
                          style: Fonts.accountDeleteInfo,
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                          bottom: accounts.length == 4 ? 100 : 0),
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        return accounts[index].id != widget.accountId
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedId = accounts[index].id;
                                  });
                                },
                                child: AccountItem(
                                  account: accounts[index],
                                  isSelected: accounts[index].id == selectedId,
                                ))
                            : Container();
                      },
                    ),
                  ),
                ],
              ),
            ),
            accounts.length > 8
                ? ButtonTransparentContainer(
                    child: Container(
                      margin: Values.buttonPadding,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Button(
                            isTransparent: true,
                            btnText: Strings.abort,
                            onTap: () {
                              Navigator.pop(context);
                            },
                            theme: ButtonColorTheme.secondaryDark,
                          ),
                          Button(
                            isTransparent: false,
                            btnText: Strings.confirm,
                            onTap: () {
                              delete();
                            },
                            theme: selectedId != ""
                                ? ButtonColorTheme.primary
                                : ButtonColorTheme.disabled,
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    margin: Values.buttonPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button(
                          isTransparent: false,
                          btnText: Strings.abort,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          theme: ButtonColorTheme.secondaryDark,
                        ),
                        Button(
                          isTransparent: false,
                          btnText: Strings.confirm,
                          onTap: () {
                            delete();
                          },
                          theme: selectedId != ""
                              ? ButtonColorTheme.primary
                              : ButtonColorTheme.disabled,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
