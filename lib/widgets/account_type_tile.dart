import 'package:flutter/material.dart';
import 'package:find_tu/constants.dart';
class AccountTypeTile extends StatefulWidget {
  Function toggleIsTutor;
  AccountTypeTile(this.toggleIsTutor);

  @override
  AccountTypeTileState createState() => AccountTypeTileState();
}

class AccountTypeTileState extends State<AccountTypeTile> {
  bool isTutor = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            debugPrint("Tutor selected");
            setState((){
              isTutor = true;
            });
            widget.toggleIsTutor();
          },
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Tutor" , style: TextStyle(color: isTutor ? appColor : Colors.grey, fontSize: 20) ),
                SizedBox(
                    height: 20
                ),
                SizedBox(
                    height: 3,
                    width: 100,
                    child: Container(
                      child: null,
                      color: isTutor ? appColor : Colors.transparent,
                    )
                ),
              ]
          ),
        ),
        GestureDetector(
          onTap: () {
            debugPrint("Student selected");
            setState((){
              isTutor = false;
            });
            widget.toggleIsTutor();
          },
          child:Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Student" , style: TextStyle(color: isTutor ? Colors.grey : appColor, fontSize: 20) ),
                SizedBox(
                    height: 20
                ),
                SizedBox(
                    height: 3,
                    width: 100,
                    child: Container(
                      child: null,
                      color: isTutor ? Colors.transparent : appColor ,
                    )
                ),
              ]
          ),
        )
      ]
    );
  }
}
