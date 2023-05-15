import 'package:flutter/material.dart';
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
    // TODO: implement initState
    super.initState();
    getData(context);
    //liste categorien von der datenbank fetchen und in preferences schmeißen
  }

  List<ColorModel> colors = [];
  List<IconModel> icons = [];
  List<CategoryModel> categoryList = [];

  void getData(BuildContext context) async {
    try {
      var response = await dio.get("http://localhost:5432/categories/1");
      debugPrint(response.data['icons'].toString());

      if (response.data != null) {
        for (var color in response.data['colors']) {
          colors.add(ColorModel.fromJson(color));
        }

        for (var icon in response.data['icons']) {
          icons.add(IconModel.fromJson(icon));
        }

        // for (var category in response.data['categories']) {
        //   categoryList.add(CategoryModel.fromJson(category));
        // }
        debugPrint(response.data['categories'].toString());
        debugPrint("colors length: ${colors.length.toString()}");
        debugPrint("icons length: ${icons.length.toString()}");

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
