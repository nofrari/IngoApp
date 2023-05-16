import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/categories/categories.dart';
import 'package:frontend/pages/guidelines.dart';
import 'package:frontend/pages/profile/profile_overview.dart';
import 'package:frontend/pages/transactions/transactions_reoccuring.dart';
import 'package:frontend/widgets/profile/option_block.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundFullScreen,
      body: Padding(
        padding: Values.accountHeading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OptionBlock(
              title: Strings.profileAccount,
              pages: const [ProfileOverview()],
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Text(Strings.profileName, style: Fonts.text100),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text("Max Mustermann", style: Fonts.text200),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Text(Strings.profileMail, style: Fonts.text100),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Text("maxmustermann@ingoapp.at",
                          style: Fonts.text200),
                    ),
                  ],
                ),
              ],
            ),
            OptionBlock(
              title: Strings.profileManage,
              pages: const [Categories(), ReoccuringTransactions()],
              children: [
                Text(Strings.profileCategory, style: Fonts.optionTitle),
                Text(Strings.profileTransactions, style: Fonts.optionTitle),
              ],
            ),
            OptionBlock(
              title: Strings.profileMore,
              pages: const [
                Guidelines(),
                //TODO replace with data protection page
                Guidelines()
              ],
              children: [
                Text(Strings.profileGuidelines, style: Fonts.optionTitle),
                Text(Strings.profileDataprotection, style: Fonts.optionTitle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
