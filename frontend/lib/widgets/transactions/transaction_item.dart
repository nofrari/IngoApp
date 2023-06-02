import 'package:flutter/material.dart';
import 'package:frontend/constants/icons.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/icon.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/pages/manual_entry.dart';
import 'package:frontend/services/transaction_service.dart';
import 'package:frontend/widgets/categories/category_icon.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../services/initial_service.dart';

class TransactionItem extends StatefulWidget {
  TransactionItem(
      {super.key, required this.transaction, this.hasBorder, this.isSmall});

  final TransactionModel transaction;
  bool? hasBorder;
  bool? isSmall;

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  List<CategoryModel> categories = [];
  @override
  Widget build(BuildContext context) {
    categories = context.watch<InitialService>().getCategories();
    CategoryModel desiredCategory = categories.firstWhere(
        (category) => category.category_id == widget.transaction.category_id);

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () async {
          await context
              .read<TransactionService>()
              .setTransaction(widget.transaction);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManualEntry(isEditMode: true),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: (widget.hasBorder != null && widget.hasBorder!)
                ? Border(
                    top: BorderSide(width: 2, color: AppColor.neutral600),
                  )
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 10, vertical: (widget.isSmall == true ? 0 : 4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 80,
                  ),
                  child: CategoryIcon(
                    isSmall: true,
                    bgColor:
                        AppColor.getColorFromString(desiredCategory.bgColor),
                    isWhite: (desiredCategory.isWhite) ? true : false,
                    icon: AppIcons.getIconFromString(desiredCategory.icon),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: widget.isSmall == true
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      widget.isSmall == true
                          ? Container()
                          : Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                widget.transaction.formattedDate,
                                style: Fonts.textDateSmall,
                              ),
                            ),
                      Row(
                        children: [
                          Text(
                            widget.transaction.transaction_name.length > 20
                                ? '${widget.transaction.transaction_name.substring(0, 20)}...'
                                : widget.transaction.transaction_name,
                            style: Fonts.textTransactionName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    widget.transaction.formattedAmount(
                        widget.transaction.transaction_amount,
                        widget.transaction.type_id.toString()),
                    style: Fonts.textHeadingBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
