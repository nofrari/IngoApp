import 'package:flutter/material.dart';
import 'package:frontend/widgets/home_overview_card.dart';
import 'package:frontend/widgets/total_amount_card.dart';

//import constants

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TotalAmountCard(totalAmount: 2500),
            HomeOverviewCard(),
          ],
        ),
      ),
    );
  }
}
