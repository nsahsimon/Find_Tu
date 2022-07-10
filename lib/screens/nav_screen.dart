import 'package:find_tu/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:find_tu/constants.dart';
import 'package:find_tu/tutor_screens/students_screen.dart';
import 'package:find_tu/student_screens/my_tutors_screen.dart';
import 'package:find_tu/screens/notification_screen.dart';

class NavigationScreen extends StatefulWidget {

  String? userType;
  NavigationScreen({this.userType = "TUTOR"});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GlobalKey<CurvedNavigationBarState> navBarKey = GlobalKey<CurvedNavigationBarState>();
  List<Icon> items = [
    Icon(Icons.home, color: navBarIconColor, size: 30),
    Icon(Icons.notifications, color: navBarIconColor, size: 30),
  ];

  List<Widget> get screenList {
    if(widget.userType == "TUTOR") {
      items = [
        Icon(Icons.home, color: navBarIconColor, size: 30),
        Icon(Icons.notifications, color: navBarIconColor, size: 30),
      ];
      return [MyStudentsScreen(), NotificationScreen()];

    }else if ( widget.userType == "STUDENT") {
      items = [
        Icon(Icons.home, color: navBarIconColor, size: 30),
        Icon(Icons.notifications, color: navBarIconColor, size: 30),
        Icon(Icons.search_sharp, color: navBarIconColor, size: 30),
      ];
      return [MyTutorsScreen(), NotificationScreen(), SearchScreen()];
    }else {
      return [MyTutorsScreen(), NotificationScreen()];
    }
  }


  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async => false,
      child: Scaffold(
        backgroundColor: screenBgColor,
        body: screenList![pageIndex],
        bottomNavigationBar: CurvedNavigationBar(
          buttonBackgroundColor: appColor,
          backgroundColor: appColor,
          color: appColor,
          key: navBarKey,
          index: pageIndex,
          items: items,
          animationDuration: const Duration(milliseconds: 100),
          onTap: (index) {
              setState((){
                pageIndex = index;
              });
          },
        ),
      ),
    );
  }
}
