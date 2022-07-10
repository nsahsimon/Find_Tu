import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:find_tu/models/notifications.dart';
import 'package:find_tu/widgets/dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationTile extends StatefulWidget {
  MyNotification notification;
  Function? startLoading;
  Function? stopLoading;
  NotificationTile(this.notification, {this.startLoading , this.stopLoading});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {

  Function get startLoading => widget.startLoading == null ? () {} :  widget.startLoading!;
  Function get stopLoading => widget.stopLoading == null ? () {} :  widget.stopLoading!;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  ///Used for tutorship request
  Future<void> confirmTutorshipRequest() async {
    startLoading();
      bool? result = await showDialog(
          context: context,
          builder: (context) => Dialogs(context).acceptTutorshipRequest(widget.notification.text));
      if(result == null){
        debugPrint("Tutor aborted dialogue box");
        stopLoading();
        return ;
      }

      ///Do this if the user accepts the tutorship request
      if (result == true) {
        try {
          await db.runTransaction((transaction) async{
            DocumentReference tutorBucketRef = db.collection("tutor_details").doc(auth.currentUser!.uid).collection("students").doc();
            DocumentReference studentBucketRef = db.collection("student_details").doc(widget.notification.senderUid).collection("tutors").doc();
            DocumentReference notificationRef = db.collection("tutor_details").doc(auth.currentUser!.uid).collection("notifications").doc(widget.notification.id);
            ///Store reference to student details in tutor database
            await tutorBucketRef.set({
              'uid': widget.notification.senderUid
            },
            SetOptions(merge: true));

            ///store reference to tutor details in student database
            await studentBucketRef.set({
              'uid' : auth.currentUser!.uid,
              'rating' : 0,
            },
            SetOptions(merge: true));

            ///Delete this particular notification
            await notificationRef.delete();

          },);
        } catch (e) {
          debugPrint("$e");
          debugPrint("(confirmTutorShip request) Failed to confirm tutorship request");
        }
      } else {
        debugPrint("The user declined the tutorship request");
      }


      ///Do this if the user rejects the tutorship request
      if(result == false) {
        DocumentReference notificationRef = db.collection("tutor_details").doc(auth.currentUser!.uid).collection("notifications").doc(widget.notification.id);
        try {
          await notificationRef.delete();
          /// todo: send a notification about a declines tutorship request
          debugPrint("This tutorship request hass been successfully declined");
        } catch (e) {
          debugPrint("$e");
          debugPrint("Failed to delete  this notification request");
        }
      }
      stopLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
      tileColor: Colors.white,
      leading: CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey,
      child: Icon(Icons.notifications, color: Colors.white,),
      ),
      title: AutoSizeText(widget.notification.text!, maxLines: 100),
      subtitle: AutoSizeText(widget.notification.creationDateTime, maxLines: 1),
      onTap:() async{
        if(widget.notification.type == "TUTORSHIP_REQUEST"){
          await confirmTutorshipRequest();
        }else {

        }
      },
      ),
    );
  }
}
