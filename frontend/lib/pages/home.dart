import 'package:flutter/material.dart';
import 'package:frontend/widgets/home_overview_card.dart';
import 'package:frontend/widgets/total_amount_card.dart';
import 'package:dio/dio.dart';

//import constants

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Dio dio = Dio();
  double _totalAmout = 0;

  @override
  void initState() {
    super.initState();
    _getTotalAmount();
  }

  void _getTotalAmount() async {
    try {
      Response response =
          await Dio().get('http://localhost:5432/accounts/totalAmount/1234');
      setState(() {
        _totalAmout = double.parse(response.data['totalAmount'].toString());
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TotalAmountCard(totalAmount: _totalAmout),
            HomeOverviewCard(),
          ],
        ),
      ),
    );
  }
}
