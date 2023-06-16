import 'package:control_style/control_style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/accounts/accounts_delete.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:frontend/widgets/three_dot_menu.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AccountCard extends StatefulWidget {
  AccountCard(
      {this.initialHeading,
      this.initialBalance,
      this.ableToDelete,
      this.isEditable,
      required this.accountId,
      required this.deleteCallback,
      required this.doneCallback,
      super.key,
      required this.onFocusChanged});

  final String? initialHeading;
  final double? initialBalance;
  final String accountId;
  bool? ableToDelete = false;
  bool? isEditable = true;
  final void Function() deleteCallback;
  final void Function() doneCallback;
  final ValueChanged<bool> onFocusChanged;

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
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß#+:'()&/^\-{2}|\s\.]"));

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

  Future<bool> tryToFinish() async {
    if (_canFinishCreating && _formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {};
      //send data
      if (_accountCardState == ThreeDotMenuState.edit) {
        formData = {
          "account_id": widget.accountId,
          "account_name": _headingController.text,
          "account_balance": currencyToDouble(_balanceController.text),
          "user_id": context.read<ProfileService>().getUser().id,
        };

        var response =
            await dio.post("${Values.serverURL}/accounts/edit", data: formData);
      } else {
        formData = {
          "account_name": _headingController.text,
          "account_balance": currencyToDouble(_balanceController.text),
          "user_id": context.read<ProfileService>().getUser().id,
        };
      }

      dynamic response;

      try {
        response = await dio.post(
            "${Values.serverURL}/accounts/${(_accountCardState == ThreeDotMenuState.edit) ? "edit" : "input"}",
            data: formData);
        debugPrint(response.toString());
      } catch (e) {
        debugPrint(e.toString());
      }

      if (_accountCardState != ThreeDotMenuState.edit) {
        await context
            .read<AccountsService>()
            .deleteAccount(id: widget.accountId);
        await context.read<AccountsService>().setAccount(
            id: response.data["account_id"],
            heading: _headingController.text,
            balance: currencyToDouble(_balanceController.text));
      }
      setState(() {
        _accountCardState = ThreeDotMenuState.collapsed;
        _isEditable = false;
        _canFinishCreating = false;
      });
      widget.doneCallback();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _headingController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
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
                            //Account name
                            child: TextFormField(
                              onTap: () => widget.onFocusChanged(true),
                              inputFormatters: [_letters],
                              controller: _headingController,
                              enabled: _isEditable,
                              style: Fonts.accountsHeading,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: "Kontoname ...",
                                hintStyle: TextStyle(
                                  color: AppColor.neutral300,
                                ),
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
                              onChanged: (value) {
                                if (_balanceController.text != "" &&
                                    _headingController.text != "") {
                                  setState(() {
                                    _canFinishCreating = true;
                                  });
                                } else if (_balanceController.text ==
                                        "0,00 €" ||
                                    _headingController.text == "") {
                                  setState(() {
                                    _canFinishCreating = false;
                                  });
                                }
                              },
                              onEditingComplete: () async {
                                FocusScope.of(context).unfocus();

                                if (_balanceController.text != "" &&
                                    _headingController.text != "") {
                                  setState(() {
                                    _canFinishCreating = true;
                                  });
                                }
                                FocusScope.of(context).unfocus();
                                widget.onFocusChanged(
                                    false); // Tastatur schließen
                                await tryToFinish();
                              },
                            ),
                          ),
                        ),
                        (widget.isEditable == true &&
                                _accountCardState != ThreeDotMenuState.create)
                            ? Container(
                                margin:
                                    const EdgeInsets.only(top: 10.0, right: 10),
                                child: ThreeDotMenu(
                                  state: _accountCardState,
                                  ableToDelete: widget.ableToDelete,
                                  onEdit: () {
                                    setState(() {
                                      _accountCardState =
                                          ThreeDotMenuState.edit;
                                      _isEditable = true;
                                    });
                                    FocusScope.of(context).unfocus();
                                    widget.onFocusChanged(
                                        false); // Tastatur schließen
                                  },
                                  onDone: () async {
                                    setState(() {
                                      _accountCardState =
                                          ThreeDotMenuState.collapsed;
                                      _isEditable = false;
                                    });

                                    //send data
                                    Map<String, dynamic> formData = {
                                      "account_id": widget.accountId,
                                      "account_name": _headingController.text,
                                      "account_balance": currencyToDouble(
                                          _balanceController.text),
                                      "user_id": context
                                          .read<ProfileService>()
                                          .getUser()
                                          .id,
                                    };

                                    var response = await dio.post(
                                        "${Values.serverURL}/accounts/edit",
                                        data: formData);
                                    debugPrint(response.toString());
                                    FocusScope.of(context).unfocus();
                                    widget.onFocusChanged(false);
                                  },
                                  onDelete: () async {
                                    dynamic response;
                                    try {
                                      response = await dio.get(
                                          "${Values.serverURL}/transactions/account/${widget.accountId}");
                                    } on DioError catch (e) {
                                      debugPrint(e.message.toString());
                                    }

                                    debugPrint(response.data.toString());
                                    if (response.data.length > 0) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AccountsDelete(
                                              accountId: widget.accountId,
                                              deleteCallback:
                                                  widget.deleteCallback),
                                        ),
                                      ).then((_) => widget.deleteCallback());
                                    } else {
                                      await context
                                          .read<AccountsService>()
                                          .deleteAccount(id: widget.accountId);
                                      await dio.delete(
                                        "${Values.serverURL}/accounts/${widget.accountId}",
                                      );

                                      widget.deleteCallback();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Start(
                                            pageId: 1,
                                          ),
                                        ),
                                      );
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
                        //Account amount
                        child: TextFormField(
                          onTap: () => widget.onFocusChanged(true),
                          inputFormatters: [currencyFormatter],
                          controller: _balanceController,
                          enabled: _isEditable && (widget.accountId == "new"),
                          style: Fonts.accountBalance,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Betrag ...",
                            hintStyle: TextStyle(
                              color: AppColor.neutral300,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte gib einen Betrag ein';
                            }
                            return null;
                          },
                          onEditingComplete: () async {
                            FocusScope.of(context).unfocus();

                            if (_balanceController.text != "" &&
                                _headingController.text != "") {
                              setState(() {
                                _canFinishCreating = true;
                              });
                            }
                            FocusScope.of(context).unfocus();
                            widget.onFocusChanged(false);
                            await tryToFinish();
                          },
                          onChanged: (value) {
                            if (_balanceController.text != "" &&
                                _headingController.text != "") {
                              setState(() {
                                _canFinishCreating = true;
                              });
                              // else if not working, but doesnt matter I guess
                            } else if (_balanceController.text == "0,00 €" ||
                                _headingController.text == "") {
                              debugPrint("happened");

                              setState(() {
                                _canFinishCreating = false;
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
                        bool couldFinish = await tryToFinish();
                        if (!couldFinish) {
                          widget.deleteCallback();
                          await context
                              .read<AccountsService>()
                              .deleteAccount(id: widget.accountId);
                        }
                        FocusScope.of(context).unfocus();
                        widget.onFocusChanged(false);
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
      ),
    );
  }
}
