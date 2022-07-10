import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tutor {
  String? name;
  String? level;
  String? type;
  String? photoLocalPath;
  String? photoUrl;
  String? location;
  String? phoneNumber;
  String? uid;
  int userRating = 0;
  List<String> subjects = [];
  Timestamp? creationTimeStamp;
  List<int> ratings = [];
  DocumentSnapshot? fbDocument;
  String subjectList = "N/A";

  Tutor (
        this.fbDocument,
       {this.name,
        this.level,
         this.subjects = const [],
        this.photoLocalPath,
        this.ratings = const [0],
        this.photoUrl,
        this.location,
         this.type,
        this.phoneNumber}) {

    if(fbDocument != null) {
      try {
        subjects = [];
        for(var subject in fbDocument!['subjects']) {
          subjects!.add(subject.toString());
        }
        subjectList = subjects!.join(",");
        name = fbDocument!["name"];
        photoUrl = fbDocument!["photo_url"];
        location = fbDocument!["location"];
        phoneNumber = fbDocument!["phone_number"];
        type = fbDocument!["type"];
        ratings = [];
        for(var rating in fbDocument!["ratings"]) {
          ratings.add(int.parse(rating));
        }
        uid = fbDocument!["uid"];
        creationTimeStamp = fbDocument!["creation_timestamp"];
      }catch(e) {
        debugPrint("$e");
        debugPrint("An error occurred when loading tutor firebase document");
      }
    }
  }

}