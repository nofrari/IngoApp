import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/userauth.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
//import constants
import '../constants/colors.dart';
import '../constants/values.dart';
import '../constants/fonts.dart';

class TotalAmountCard extends StatefulWidget {
  const TotalAmountCard({super.key});
  @override
  State<TotalAmountCard> createState() => _TotalAmountCardState();
}

class _TotalAmountCardState extends State<TotalAmountCard> {
  Dio dio = Dio();
  late Future<double> _totalAmount;

  Future<double> _getTotalAmount() async {
    User user = context.read<ProfileService>().getUser();
    dio.options.headers['authorization'] = 'Bearer ${user.token}';
    try {
      Response response =
          await dio.get('${Values.serverURL}/accounts/totalAmount/${user.id}');
      return Future.value(
          double.parse(response.data['totalAmount'].toString()));
    } on DioError catch (dioError) {
      debugPrint(dioError.toString());
      logOut(dioError, context);
      return Future.value(0.0);
    } catch (e) {
      debugPrint(e.toString());
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
