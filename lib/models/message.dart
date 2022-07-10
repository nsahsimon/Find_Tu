import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Message {
  String text;
  String? senderUid;
  Timestamp? timeStamp;
  DocumentSnapshot? fbDoc;
  Message(fbDoc, {this.text = "add some text", this.timeStamp, this.senderUid}){
    if(fbDoc != null) {
      try {
        senderUid = fbDoc["sender_uid"];
        text = fbDoc["text"];
        timeStamp = fbDoc["timestamp"];
      } catch (e) {
        debugPrint("$e");
        debugPrint(">> (message) Failed to message info from firebase document");
      }
    }
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///Check if this user is the sender of the message
  bool get isSent {
    if(_auth.currentUser!.uid == senderUid) {
      return true;
    } else {
      return false;
    }
  }

}