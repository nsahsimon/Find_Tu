import "package:flutter/material.dart";
import 'package:find_tu/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RoundedButton extends StatelessWidget {
  String? text;
  double? width;
  double? height;
  double? radius;
  Icon? icon;
  void Function()? onTap;

  RoundedButton({this.text, this.width, this.height, this.radius = 20, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap ?? (){/*do nothing */},
        child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius ?? 20),
              color: appColor,
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon ?? Container(child: null),
                  !(icon == null) ?  const SizedBox(width: 10) : Container(child: null),
                  AutoSizeText(text?? "add text", style: TextStyle(color: Colors.white, fontSize: 20))
                ]
            )
        ),
      ),
    );
  }
}

