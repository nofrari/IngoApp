import 'package:flutter/material.dart';
import 'package:frontend/constants/icons.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/icon.dart';
import 'package:frontend/models/transaction.dart';
import 'package:frontend/widgets/categories/category_icon.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../services/initial_service.dart';

class TransactionItem extends StatefulWidget {
  const TransactionItem({super.key, required this.transaction});

  final TransactionModel transaction;

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

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2, color: AppColor.neutral600),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              constraints: const BoxConstraints(
                maxWidth: 80,
              ),
              child: CategoryIcon(
                isSmall: true,
                bgColor: AppColor.getColorFromString(desiredCategory.bgColor),
                isWhite: true,
                icon: AppIcons.getIconFromString(desiredCategory.icon),
              ),
            ),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transaction.formattedDate,
                      style: Fonts.textDateSmall,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Text(
                          widget.transaction.transaction_name,
                          style: Fonts.textTransactionName,
                        ),
                      ],
                    )
                  ],
                ),
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
    );
  }
}
