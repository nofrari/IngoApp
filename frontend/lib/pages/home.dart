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
  double _totalAmout = 0;

  @override
  void initState() {
    super.initState();
    _getTotalAmount();
    getData(context);
  }

  List<ColorModel> colors = [];
  List<IconModel> icons = [];

  void _getTotalAmount() async {
    try {
      Response response = await Dio().get(
          '${Values.serverURL}/accounts/totalAmount/${context.read<ProfileService>().getUser().id}');
      setState(() {
        _totalAmout = double.parse(response.data['totalAmount'].toString());
      });
    } catch (e) {
      print(e);
    }
  }

  void getData(BuildContext context) async {
    try {
      var response = await dio.get(
          "${Values.serverURL}/categories/${context.read<ProfileService>().getUser().id}");
      debugPrint("icons: ${response.data['icons'].toString()}");

      if (response.data != null) {
        for (var color in response.data['colors']) {
          colors.add(ColorModel.fromJson(color));
        }

        for (var icon in response.data['icons']) {
          icons.add(IconModel.fromJson(icon));
        }

        await context.read<InitialService>().setColors(colors);
        await context.read<InitialService>().setIcons(icons);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    //response listen zu categorie liste und in shared pref
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
