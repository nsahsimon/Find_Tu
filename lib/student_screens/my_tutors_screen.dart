import 'package:find_tu/models/tutor.dart';
import 'package:find_tu/widgets/initials_tab.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_tu/widgets/tutor_tile.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:find_tu/data/tutors_data.dart';
import 'package:find_tu/data/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_tu/processes/user_auth.dart';

import '../constants.dart';

class MyTutorsScreen extends StatefulWidget {
  @override
  _MyTutorsScreenState createState() => _MyTutorsScreenState();
}

class _MyTutorsScreenState extends State<MyTutorsScreen> {

  TutorsData get provider => Provider.of<TutorsData>(context);
  UserData get userData => Provider.of<UserData>(context);
  FirebaseAuth  auth = FirebaseAuth.instance;

  bool isLoading = false;

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

  Future<List<Map<String, dynamic>>> getTutorDocs(QuerySnapshot tutorIdCollection) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<DocumentSnapshot> tutorIdDocuments = tutorIdCollection.docs;
    List<Map<String, dynamic>> tutorDocs = [];
    for(DocumentSnapshot doc in tutorIdDocuments) {
      String tutorDocId = doc["uid"];
      int tutorRating = 0;
      try{
        tutorRating = doc["rating"];
      }catch(e) {
        debugPrint("$e");
        debugPrint("Unable to find the field name \" rating \" in the tutorDocument");
      }
      DocumentSnapshot? tutorDoc;
      try{
        tutorDoc = await db.collection("tutor_details").doc(tutorDocId).get();
      }catch(e) {
        debugPrint("$e");
        debugPrint("(getTutorDocs) unable to get the tutor details of some tutor");
      }
      if(tutorDoc != null) {
        tutorDocs.add({"tutor_doc": tutorDoc, "rating": tutorRating});
      }
    }

    return tutorDocs;
  }

  Stream<QuerySnapshot>? get _stream {
      return FirebaseFirestore.instance.collection("student_details").doc(auth.currentUser!.uid).collection("tutors").snapshots();
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
                leading: InitialsTab("${userData.userName}"),
                title: Center(child: AutoSizeText("My Tutors")),
                actions: [
                  IconButton(icon: Icon(Icons.logout, color: Colors.white,), onPressed: ()async{ await UserAuth(context: context).signOut(resetFirstTime: true);},)
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
                  if(snapshot.data != null) {
                    getTutorDocs(snapshot.data!).then((tutorDocs) {
                      Provider.of<TutorsData>(context, listen: false).loadTutors(tutorDocs, context);
                    });
                  } else {
                    Provider.of<TutorsData>(context, listen: false).emptyTutorList();
                  }


                }
                return ModalProgressHUD(
                  inAsyncCall: isLoading,
                  child: provider.tutorCount == 0 ? Center(child: Text("No tutors yet")) : ListView.builder(
                      itemCount: provider.tutorCount,
                      itemBuilder: (context, i) => TutorTile(provider.getTutorAtIndex(i), startLoading: startLoading, stopLoading: stopLoading, canDelete: true, showRating: true,)),
                );
              }
            )
        )
    );
  }
}
