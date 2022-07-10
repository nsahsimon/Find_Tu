import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_tu/models/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsData extends ChangeNotifier {
  List<MyNotification> _myNotifications = [];

  set addNotification(MyNotification newNotification) {
    _myNotifications.add(newNotification);
    notifyListeners();
  }

  set deleteNotification(MyNotification oldStudent) {
    int noteIndex = _myNotifications.indexOf(oldStudent);
    _myNotifications.removeAt(noteIndex);
    notifyListeners();
  }

  List<MyNotification> get notifications => _myNotifications;

  void loadNotifications(List<DocumentSnapshot> docs, {bool notify = true}) {
    _myNotifications = [];
    for(DocumentSnapshot doc in docs) {
      MyNotification newNotification = MyNotification(
          null,
        type: doc["type"],
        text: doc["text"],
        senderUid: doc["sender_uid"],
        creationTimestamp: doc["creation_timestamp"],
        id: doc.reference.id.toString(),
      );
      _myNotifications.add(newNotification);
    }
    if(notify) notifyListeners();
  }

  int get notificationCount => _myNotifications.length;
  MyNotification getNoteAtIndex (int index) => _myNotifications[index];
}