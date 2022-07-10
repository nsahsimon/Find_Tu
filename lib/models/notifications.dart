import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyNotification {
  String type ;
  String text;
  String senderUid;
  String? id;
  Timestamp? creationTimestamp;
  DocumentSnapshot? fbDocument;
  MyNotification(this.fbDocument, {this.type= "TUTORSHIP_REQUEST", this.creationTimestamp, this.text = "hello. I'm a notification", this.id, this.senderUid= ""}) {
    try  {
      if (fbDocument != null) {
        type = fbDocument!["type"];
        text = fbDocument!["text"];
        senderUid = fbDocument!["sender_uid"];
        creationTimestamp = fbDocument!["creation_timestamp"];
        id = fbDocument!.reference.id.toString();
      }
    }catch(e) {
      debugPrint("$e");
      debugPrint("Failed to extract the notification details");
    }
  }

  String get creationDateTime {
    if(creationTimestamp == null) return "N/A";
    return creationTimestamp!.toDate().toLocal().toString();
  }
}