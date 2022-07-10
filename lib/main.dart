import 'package:flutter/material.dart';
import 'package:find_tu/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:find_tu/data/notification_data.dart';
import 'package:find_tu/data/students_data.dart';
import 'package:find_tu/data/tutors_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:find_tu/processes/local_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_tu/data/user_data.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
  await LocalStorage().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        ChangeNotifierProvider<StudentsData>(create: (_) => StudentsData()),
        ChangeNotifierProvider<TutorsData>(create: (_) => TutorsData()),
        ChangeNotifierProvider<NotificationsData>(create: (_) => NotificationsData()),
        ChangeNotifierProvider<UserData>(create: (_) => UserData())
      ],
      builder:(context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FindTu',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: Colors.purple,
        ),
        home: SplashScreen(),
      )
    );
  }
}

