import 'package:find_tu/data/user_data.dart';
import 'package:flutter/material.dart';
import 'package:find_tu/models/tutor.dart';
import 'package:find_tu/widgets/tutor_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_tu/widgets/search_method_tile.dart';
import 'package:find_tu/constants.dart';
import 'package:find_tu/widgets/dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_tu/data/user_data.dart';


class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  bool isLoading = false;
  String searchMethod = "name";
  String searchKey = "";

  UserData get userData => Provider.of(context, listen: false);
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


  void toggleSearchMethod() {
    setState((){
      if(searchMethod == "name") {
        searchMethod =  "subject";
      }
      else if(searchMethod == "subject") {
        searchMethod =  "name";
      }
    });
  }

  TextEditingController _controller = TextEditingController();

  Future<void> findTutor() async{

  }

  UserData get userDataProvider => Provider.of<UserData>(context);
  List<Tutor> searchedTutors = [];
  int get resultCount => searchedTutors.length;

  Future<void> requestTutorship(Tutor tutor) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference tutorNotificationRef = db.collection("tutor_details").doc("${tutor.uid}").collection("notifications").doc();
    Query tutorNotificationCheckRef = db.collection("tutor_details")
        .doc("${tutor.uid}")
        .collection("notifications")
        .where('sender_uid', isEqualTo: auth.currentUser!.uid)
        .where('type', isEqualTo: "TUTORSHIP_REQUEST");
    ///First check if the tutorship request has been sent
    try {
      QuerySnapshot notiDocs = await tutorNotificationCheckRef.get();
      try{
       if(notiDocs.docs.isNotEmpty) {
         debugPrint("A tutorship request has aleady been sent");
         return ;
       }
      }catch(e) {
        debugPrint("$e");
        debugPrint("A tutorship request might have been sent");
        return ;
      }
    }catch(e){
      debugPrint("$e");
      debugPrint("Failed to check if the tutorship request already exists");
      //todo: display request check failed exclamation dialog
      return ;
    }

   bool result =  await showDialog(
       context: context,
       builder: (context)=> Dialogs(context).showTutorDetails(tutor));
   if(result == true) {
     try {
       ///upload the tutorship notification request
       await tutorNotificationRef
           .set( {
              'type' : "TUTORSHIP_REQUEST",
              'text' : "${userData.userName!.toUpperCase()}, has sent you a tutorship request.You can either accept or reject this request",
              'sender_uid' : auth.currentUser!.uid,
              'creation_timestamp' : FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));

       //todo: Show confirmatin dialog
     } catch (e) {
       debugPrint("$e");
       debugPrint("(search) screen failed to send tutorship request");
       return;
     }

   } else {
     debugPrint("The user refused to send the tutorship request");
     return ;
   }
  }


  Stream<QuerySnapshot>? get _stream {
    if(searchMethod == "name") {
      debugPrint("Searching for tutors using name Key");
      return FirebaseFirestore.instance.collection("tutor_details").where("name_keys", arrayContains: searchKey.trim().toLowerCase()).snapshots();
    }else if(searchMethod == "subject") {
      debugPrint("Searching for tutors using subject key");
      return FirebaseFirestore.instance.collection("tutor_details").where("subject_keys", arrayContains: searchKey.trim().toLowerCase()).snapshots();
    } else {
      //todo: Add default search log
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: screenBgColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
              title: Center(child: AutoSizeText("Find Tutor"))
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
              searchedTutors = [];
              for(DocumentSnapshot tutorDoc in snapshot.data!.docs) {
                Tutor newTutor = Tutor(tutorDoc);
                searchedTutors.add(newTutor);
              }

              debugPrint("Found ${searchedTutors.length} tutors");
            }


            return ModalProgressHUD(
              inAsyncCall: isLoading,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          SearchMethodTile(toggleSearchMethod),
                          SizedBox(
                              height: 10),
                          Container(
                            color: Colors.white,
                            child: TextField(
                              onChanged: (newText) {
                                if(_controller.text.trim() != "") {
                                  setState((){
                                    searchKey = _controller.text;
                                  });
                                }
                              },
                              controller: _controller,
                              minLines: 1,
                              maxLines: 10,
                              decoration: InputDecoration(
                                  hintText: "Enter ${searchMethod.toUpperCase()} here",
                                  suffixIcon: IconButton(icon: Icon(Icons.search_sharp), color: appColor,
                                    onPressed: () async{
                                      if(_controller.text != null && _controller.text.trim() != "") {
                                        setState((){
                                          searchKey = _controller.text;
                                        });
                                        _controller.text = "";
                                      }
                                    },)
                              ),
                            ),
                          ),
                          SizedBox(
                              height: 10),
                        ]
                      ),
                    )
                  ),

                  Expanded(
                    child: resultCount == 0 ? Center(child: Text("Oops no tutors found")) : ListView.builder(
                      itemCount: resultCount,
                        itemBuilder: (context, i) {
                          return TutorTile(searchedTutors[i], startLoading: startLoading, stopLoading: stopLoading, showRating: true, onTap: ()async{ await requestTutorship(searchedTutors[i]);},);
                        }),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
