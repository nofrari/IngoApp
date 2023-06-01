import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
//import constants
import '../constants/colors.dart';
import '../constants/values.dart';
import '../constants/fonts.dart';

class TotalAmountCard extends StatefulWidget {
  TotalAmountCard({super.key});
  @override
  State<TotalAmountCard> createState() => _TotalAmountCardState();
}

class _TotalAmountCardState extends State<TotalAmountCard> {
  Dio dio = Dio();
  late Future<double> _totalAmount;

  Future<double> _getTotalAmount() async {
    try {
      Response response = await Dio().get(
          '${Values.serverURL}/accounts/totalAmount/${context.read<ProfileService>().getUser().id}');
      return Future.value(
          double.parse(response.data['totalAmount'].toString()));
    } catch (e) {
      print(e);
      return Future.value(0.0);
    }
  }

  @override
  void initState() {
    _totalAmount = _getTotalAmount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Values.cardRadius),
          color: AppColor.neutral500),
      padding: Values.smallCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Gesamtvermögen",
            style: Fonts.text300,
          ),
          Text(
            "aus allen Konten",
            style: Fonts.text100,
          ),
          FutureBuilder<double>(
            future: _totalAmount,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Text(
                    formatedAmount(
                        snapshot.data == null ? 0.0 : snapshot.data!),
                    style: Fonts.text400);
              }
            },
          ),
        ],
      ),
    );
  }

  String formatedAmount(double amount) {
    var formatter = NumberFormat('#,##0.00', 'de_DE');
    String formattedNumber = formatter.format(amount);

    return "$formattedNumber €";
  }
}
