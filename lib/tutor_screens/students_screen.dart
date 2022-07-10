import 'package:find_tu/models/student.dart';
import 'package:find_tu/widgets/initials_tab.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_tu/widgets/student_tile.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:find_tu/data/students_data.dart';
import 'package:find_tu/data/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_tu/processes/user_auth.dart';

import '../constants.dart';


class MyStudentsScreen extends StatefulWidget {
  @override
  _MyStudentsScreenState createState() => _MyStudentsScreenState();
}

class _MyStudentsScreenState extends State<MyStudentsScreen> {

  StudentsData get provider => Provider.of<StudentsData>(context);
  UserData get userData => Provider.of<UserData>(context);
  FirebaseAuth  auth = FirebaseAuth.instance;

  bool isLoading = false;
  var prevSnapshot;

  void startLoading() {
    setState((){
      isLoading = true;
    });
  }

  void stopLoading() {
    setState((){
      isLoading = false;
    });
  }

  Future<List<DocumentSnapshot>> getStudentDocs(QuerySnapshot studentIdCollection) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<DocumentSnapshot> studentIdDocuments = studentIdCollection.docs;
    debugPrint("Found ${studentIdDocuments} student Id documents");
    List<DocumentSnapshot> studentDocs = [];
    for(DocumentSnapshot doc in studentIdDocuments) {
      String studentDocId = doc["uid"];
      debugPrint("(getStudentDocs) found this student uid: ${studentDocId}");
      DocumentSnapshot? studentDoc;
      try{
        studentDoc = await db.collection("student_details").doc(studentDocId).get();
      }catch(e) {
        debugPrint("$e");
        debugPrint("(getStudentDocs) unable to get the student details of some tutor");
      }
      if(studentDoc != null) {
        studentDocs.add(studentDoc);
      }
    }

    return studentDocs;
  }

  Stream<QuerySnapshot>? get _stream {
    return FirebaseFirestore.instance.collection("tutor_details").doc(auth.currentUser!.uid).collection("students").snapshots();
  }

  @override
  void initState(){
    super.initState();
    //todo: load students;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: screenBgColor,
        appBar: AppBar(
          leading: InitialsTab(userData.userName!),
          title: Center(child: AutoSizeText("My Students")),
          actions: [
            IconButton(icon: Icon(Icons.logout, color: Colors.white,), onPressed: ()async{ await UserAuth(context: context).signOut(resetFirstTime: true);} ,)
          ]
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (context, snapshot) {
            if(snapshot.hasError) {
              isLoading = false;
              debugPrint("An error occurred");
            }

            if(snapshot.connectionState == ConnectionState.waiting) {
              isLoading = true;
              debugPrint("Waiting for connection");
            }

            if(snapshot.hasData) {
              isLoading = false;
              debugPrint("Got data from firebase");
              ///Load tutor data
              ///Empty searched Tutors
              if(snapshot.data != null ) {
                getStudentDocs(snapshot.data!)
                    .then((value) {
                  Provider.of<StudentsData>(context, listen: false).loadStudents(value, context);
                });
              } else {
                debugPrint("snapshot data is null");
                Provider.of<StudentsData>(context, listen: false).empty();
              }


            }

            return ModalProgressHUD(
              inAsyncCall: isLoading,
              child: provider.studentCount == 0 ? Center(child: Text("No students yet")) : ListView.builder(
                  itemCount: provider.studentCount,
                  itemBuilder: (context, i) => StudentTile(provider.getStudentAtIndex(i))),
            );
          }
        )
      )
    );
  }
}
