import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/widgets/round_button.dart';

enum ThreeDotMenuState { collapsed, expanded, create, edit, done }

class ThreeDotMenu extends StatefulWidget {
  ThreeDotMenu(
      {super.key,
      required this.onEdit,
      required this.onDelete,
      required this.onDone,
      required this.state,
      required this.onStateChange});

  final void Function() onEdit;
  final void Function() onDelete;
  final void Function() onDone;
  ThreeDotMenuState state;
  final ValueChanged<ThreeDotMenuState> onStateChange;

  @override
  State<ThreeDotMenu> createState() => _ThreeDotMenuState();
}

class _ThreeDotMenuState extends State<ThreeDotMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: Values.roundButtonSize,
          height: Values.roundButtonSize,
          margin: const EdgeInsets.only(bottom: 5),
          child: RoundButton(
            borderWidth: 1.5,
            onTap: () {
              widget.onStateChange(widget.state == ThreeDotMenuState.collapsed
                  ? ThreeDotMenuState.expanded
                  : ThreeDotMenuState.collapsed);
              widget.state == ThreeDotMenuState.edit ? widget.onDone() : null;
            },
            icon: widget.state == ThreeDotMenuState.edit
                ? Icons.done_rounded
                : Icons.more_horiz_rounded,
            padding: 0.0,
            color: widget.state == ThreeDotMenuState.expanded
                ? AppColor.neutral100
                : null,
          ),
        ),
        //Edit Button
        widget.state == ThreeDotMenuState.expanded &&
                widget.state != ThreeDotMenuState.edit
            ? Container(
                width: Values.roundButtonSize,
                height: Values.roundButtonSize,
                margin: const EdgeInsets.only(bottom: 5),
                child: RoundButton(
                  borderWidth: 1.5,
                  onTap: widget.onEdit,
                  icon: Icons.edit,
                  padding: 0.0,
                  iconSize: 20,
                ),
              )
            : Container(),
        //Delete Button
        widget.state == ThreeDotMenuState.expanded &&
                widget.state != ThreeDotMenuState.edit
            ? SizedBox(
                width: Values.roundButtonSize,
                height: Values.roundButtonSize,
                child: RoundButton(
                  borderWidth: 1.5,
                  onTap: widget.onDelete,
                  icon: Icons.delete,
                  padding: 0.0,
                  iconSize: 20,
                ),
              )
            : Container(),
      ],
    );
  }
}
