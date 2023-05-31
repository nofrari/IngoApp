import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/widgets/profile/option.dart';

class OptionBlock extends StatelessWidget {
  const OptionBlock(
      {required this.title,
      required this.children,
      required this.pages,
      super.key});
  final String title;
  final List<Widget> children;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: (children.length == 1 ? 10 : 0)),
              child: Text(title, style: Fonts.textHeadingBold),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: children.length,
                itemBuilder: (context, index) {
                  return children.length == 1
                      ? Option(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => pages[index]),
                            );
                          },
                          child: children[index],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            border: index < children.length - 1
                                ? Border(
                                    bottom: BorderSide(
                                      color: AppColor.blueActive,
                                      width: 0.5,
                                    ),
                                  )
                                : const Border.fromBorderSide(BorderSide.none),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Option(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => pages[index]),
                                );
                              },
                              child: children[index],
                            ),
                          ),
                        );
                }),
            //
            // ListView(
            //   shrinkWrap: true,
            //   children: children
            //       .map((optionitem) => children.length == 1
            //           ? Option(
            //               child: optionitem,
            //             )
            //           : Container(
            //               decoration: BoxDecoration(
            //                 border: Border(
            //                   bottom: BorderSide(
            //                     color: AppColor.blueActive,
            //                     width: optionitem. 0.75,
            //                   ),
            //                 ),
            //               ),
            //               child: Padding(
            //                 padding: const EdgeInsets.symmetric(vertical: 10.0),
            //                 child: Option(
            //                   child: optionitem,
            //                 ),
            //               ),
            //             ))
            //       .toList(),
            // ),
          ],
        ),
      ),
    );
  }
}
