import 'package:flutter/material.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:frontend/widgets/home_overview_card.dart';
import 'package:frontend/widgets/total_amount_card.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/color.dart';
import 'package:frontend/models/icon.dart';
import 'package:dio/dio.dart';
import 'package:frontend/services/initial_service.dart';
import 'package:provider/provider.dart';
//import constants

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TotalAmountCard(),
            HomeOverviewCard(),
          ],
        ),
      ),
    );
  }
}
