import 'package:flutter/material.dart';
import 'package:find_tu/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ChatTile extends StatelessWidget {
  bool isSent;
  String msg;
  Color get tileColor => isSent ? sendChatTileColor : receiveChatTileColor;
  Color get textColor => isSent ? sendTextColor : receiveTextColor;
  ChatTile({this.isSent = true, this.msg = "Hi, there is no message"});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: isSent
          ? Row(
        mainAxisAlignment:MainAxisAlignment.end,
        children: [
          Expanded(flex: 2, child: SizedBox(width: 50,)),
          Flexible(
            flex: 8,
            child: Container(
              decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                child: AutoSizeText(
                    msg,
                    maxLines: 1000,
                    style: TextStyle(
                        color: textColor,
                    )
                ),
              ),
            ),
          ),


        ],
      )
      : Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 8,
            child: Container(
              decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                child: AutoSizeText(
                    msg,
                    maxLines: 1000,
                    style: TextStyle(
                      color: textColor,
                    )
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: SizedBox(width: 50,)),

        ],
      ),
    );
  }
}
