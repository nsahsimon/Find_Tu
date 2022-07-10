import 'package:flutter/material.dart';
import 'package:find_tu/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_tu/screens/nav_screen.dart';
import 'package:find_tu/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_tu/data/user_data.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<List> getUserData(String? userId) async{
    ///retrieve user doc from firebase
    String? userType;
    DocumentSnapshot? userDoc;
    try {
      var userDocFuture = FirebaseFirestore.instance.collection("tutor_details").doc(userId).get();
      userDoc = await userDocFuture;
      if(!userDoc.exists){
        var userDocFuture = FirebaseFirestore.instance.collection("student_details").doc(userId).get();
        userDoc = await userDocFuture;
        if(!userDoc.exists) {
          userType = null;
        }else {
          debugPrint('(login) user is a STUDENT');
          userType = "STUDENT";
        }
      } else {
        debugPrint("(login) user  is a TUTOR");
        userType = "TUTOR";
      }
    } on Exception catch (e) {
      debugPrint("unable to get user data");
    }
    return [userType,userDoc];

  }

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 5),
            () async {
      if(auth.currentUser == null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        List user = await getUserData(auth.currentUser!.uid);
        String? userType = user[0];
        DocumentSnapshot? userDoc = user[1];
        if(userType != null) {
          ///Load user data
          Provider.of<UserData>(context, listen: false).loadUserData(userDoc!);
          Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(userType: userType)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }


        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // if(prefs.containsKey("${auth.currentUser!.uid}")) {
        //   String? userType = prefs.getString("${auth.currentUser!.uid}_userType");
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(userType: userType)));
        // }
              }

            });
    //todo: Add app initialization logic here
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text("findTu", style: TextStyle(color: appColor, fontSize: 30)),
          )
        ));
  }
}
