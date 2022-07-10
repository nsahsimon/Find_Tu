import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Student {
  String? name;
  String? level;
  String? photoLocalPath;
  String? photoUrl;
  String? location;
  String? phoneNumber;
  String? uid;
  String? type;
  Timestamp? creationTimeStamp;
  DocumentSnapshot? fbDocument;

  Student (
      this.fbDocument,
      {this.name,
        this.level,
        this.photoLocalPath,
        this.photoUrl,
        this.location,
        this.type,
        this.phoneNumber}) {

    if(fbDocument != null) {
      try {
        name = fbDocument!["name"];
        photoUrl = fbDocument!["photo_url"];
        location = fbDocument!["location"];
        phoneNumber = fbDocument!["phone_number"];
        uid = fbDocument!["uid"];
        level = fbDocument!["level"];
        type = fbDocument!["type"];
        creationTimeStamp = fbDocument!["creation_timestamp"];
      }catch(e) {
        debugPrint("$e");
        debugPrint("(student) An error occurred when loading student firebase document");
      }
    }
  }

}