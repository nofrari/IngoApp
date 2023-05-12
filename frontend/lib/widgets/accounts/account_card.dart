import 'package:control_style/control_style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:frontend/widgets/three_dot_menu.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AccountCard extends StatefulWidget {
  const AccountCard(
      {this.initialHeading,
      this.initialBalance,
      required this.accountId,
      this.deleteCallback,
      super.key});

  final String? initialHeading;
  final double? initialBalance;
  final String accountId;
  final void Function()? deleteCallback;

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  final _formKey = GlobalKey<FormState>();
  final _headingController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _isEditable = false;
  bool _canFinishCreating = false;
  ThreeDotMenuState _accountCardState = ThreeDotMenuState.collapsed;
  Dio dio = Dio();

  final TextInputFormatter _letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s]"));

  void onStateChanged(ThreeDotMenuState accountCardState) {
    setState(() {
      _accountCardState = accountCardState;
    });
  }

  @override
  void initState() {
    super.initState();

    // if ((widget.initialBalance == null || widget.initialBalance == 0) &&
    //     widget.initialHeading == null) {
    if (widget.accountId == "new") {
      onStateChanged(ThreeDotMenuState.create);
      setState(() {
        _isEditable = true;
      });
    } else {
      _headingController.text = widget.initialHeading!;
      _balanceController.text =
          NumberFormat("#,##0.00 €", "de_DE").format(widget.initialBalance);
    }
  }

  @override
  void dispose() {
    _headingController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
      ),
      height: _accountCardState == ThreeDotMenuState.create
          ? Values.accountCardHeight + Values.roundButtonSize / 2
          : Values.accountCardHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: EdgeInsets.only(
                bottom: _accountCardState == ThreeDotMenuState.create
                    ? Values.roundButtonSize / 2
                    : 0),
            height: Values.accountCardHeight,
            decoration: BoxDecoration(
              color: AppColor.neutral500,
              borderRadius: BorderRadius.circular(Values.cardRadius),
            ),
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 15.0, left: 15),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: TextFormField(
                            inputFormatters: [_letters],
                            controller: _headingController,
                            enabled: _isEditable,
                            style: Fonts.accountsHeading,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.neutral100),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.neutral100),
                              ),
                              disabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bitte gib einen Namen ein';
                              }
                              return null;
                            },
                            onEditingComplete: () {
                              if (_balanceController.text != "" &&
                                  _headingController.text != "") {
                                setState(() {
                                  _canFinishCreating = true;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      _accountCardState != ThreeDotMenuState.create
                          ? Container(
                              margin:
                                  const EdgeInsets.only(top: 10.0, right: 10),
                              child: ThreeDotMenu(
                                state: _accountCardState,
                                onEdit: () {
                                  setState(() {
                                    _accountCardState = ThreeDotMenuState.edit;
                                    _isEditable = true;
                                  });
                                },
                                onDone: () async {
                                  setState(() {
                                    _accountCardState = ThreeDotMenuState.done;
                                    _isEditable = false;
                                  });

                                  //send data
                                  Map<String, dynamic> formData = {
                                    "account_id": widget.accountId,
                                    "account_name": _headingController.text,
                                    "account_balance": currencyToDouble(
                                        _balanceController.text),
                                    "user_id": "1",
                                  };

                                  var response = await dio.post(
                                      "${Values.serverURL}/accounts/edit",
                                      data: formData);
                                  debugPrint(response.toString());
                                },
                                onDelete: () async {
                                  await dio.delete(
                                    "${Values.serverURL}/accounts/${widget.accountId}",
                                  );
                                  await context
                                      .read<AccountsService>()
                                      .deleteAccount(widget.accountId);
                                  if (widget.deleteCallback != null) {
                                    widget.deleteCallback!();
                                  }
                                },
                                onStateChange: onStateChanged,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextFormField(
                        inputFormatters: [currencyFormatter],
                        controller: _balanceController,
                        enabled: _isEditable,
                        style: Fonts.accountBalance,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColor.neutral100),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColor.neutral100),
                          ),
                          disabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte gib einen Betrag ein';
                          }
                          return null;
                        },
                        onEditingComplete: () {
                          if (_balanceController.text != "" &&
                              _headingController.text != "") {
                            setState(() {
                              _canFinishCreating = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _accountCardState == ThreeDotMenuState.create
              ? Container(
                  width: Values.roundButtonSize,
                  height: Values.roundButtonSize,
                  child: RoundButton(
                    borderWidth: 1.5,
                    onTap: () async {
                      if (_canFinishCreating &&
                          _formKey.currentState!.validate()) {
                        //send data
                        Map<String, dynamic> formData = {
                          "account_name": _headingController.text,
                          "account_balance":
                              currencyToDouble(_balanceController.text),
                          "user_id": "1",
                        };

                        var response = await dio.post(
                            "${Values.serverURL}/accounts/input",
                            data: formData);
                        debugPrint(response.toString());

                        setState(() {
                          _accountCardState = ThreeDotMenuState.done;
                          _isEditable = false;
                          _canFinishCreating = false;
                        });
                        await context.read<AccountsService>().setAccount(
                            id: response.data["account_id"],
                            heading: _headingController.text,
                            balance: currencyToDouble(_balanceController.text));
                      } else {
                        if (widget.deleteCallback != null) {
                          widget.deleteCallback!();
                        }
                        await context
                            .read<AccountsService>()
                            .deleteAccount(widget.accountId);
                      }
                    },
                    icon: (_canFinishCreating)
                        ? Icons.done_rounded
                        : Icons.close_rounded,
                    padding: 0.0,
                    iconSize: 20,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
