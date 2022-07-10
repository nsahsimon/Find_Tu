import 'package:find_tu/constants.dart';
import 'package:flutter/material.dart';
import 'package:find_tu/widgets/notification_tile.dart';
import 'package:provider/provider.dart';
import 'package:find_tu/data/notification_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_tu/data/user_data.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NotificationScreen extends StatefulWidget {

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}



class _NotificationScreenState extends State<NotificationScreen> {
  NotificationsData get notificationsProvider => Provider.of<NotificationsData>(context);
  UserData get userData => Provider.of<UserData>(context);

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: screenBgColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
            title: Center(child: AutoSizeText("Notifications"))
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("${userData.userType!.toLowerCase()}_details")
              .doc("${userData.userId}")
              .collection("notifications")
              .orderBy('creation_timestamp',descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasError) {
              isLoading = false;
              debugPrint("Snapshot has error");
            } else if(snapshot.connectionState == ConnectionState.waiting){
              isLoading = true;
              debugPrint("Snapshot is still loading");
            } else {
              notificationsProvider.loadNotifications(snapshot.data!.docs, notify: false);
              isLoading = false;
            }
            return ModalProgressHUD(
              inAsyncCall: isLoading,
              child: notificationsProvider.notificationCount == 0 ? const Center(child: Text("No notifications yet")) : ListView.builder(
                itemCount: notificationsProvider.notificationCount,
                itemBuilder: (context, i) {
                  return NotificationTile(notificationsProvider.notifications[i], startLoading: startLoading, stopLoading: stopLoading);
                },
              ),
            );
          }
        ),
      ),
    );
  }
}
