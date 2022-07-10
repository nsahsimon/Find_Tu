import 'package:flutter/material.dart';
import 'package:find_tu/screens/edit_account_screen.dart';

class InitialsTab extends StatefulWidget {
  String name;
  InitialsTab(this.name);

  @override
  _InitialsTabState createState() => _InitialsTabState();
}

class _InitialsTabState extends State<InitialsTab> {

  String genInitials() {
    List<String> initialsList = [];
    List<String> names = widget.name.trim().replaceAll("  ", " ").split(" ");
    for(String name in names) {
      name.length != 0 ? initialsList.add(name[0]) : null;
    }
    return initialsList.join();
  }
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: CircleAvatar(
        radius: 70,
          backgroundColor: Colors.pink,
          child: Center(
            child: Text(
              genInitials(),
            ),
          )),
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => EditingAccountScreen()));
      },
    );
  }
}
