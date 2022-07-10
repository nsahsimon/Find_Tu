import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_tu/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_tu/constants.dart';
import 'package:find_tu/widgets/chat_tile.dart';
import 'package:find_tu/data/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_tu/constants.dart';
import 'package:find_tu/widgets/profile_pic.dart';

class ChatScreen extends StatefulWidget {
  dynamic chat; //This chat can either a tutor or a student
  ChatScreen(this.chat);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  UserData get userData => Provider.of<UserData>(context);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), (){
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
    });

  }

  Stream<QuerySnapshot>? get _stream {
    FirebaseAuth auth = FirebaseAuth.instance;
    if(userData.userType == 'TUTOR') {
      return FirebaseFirestore.instance.collection("tutor_details").doc(auth.currentUser!.uid).collection("chats").doc("${widget.chat.uid!}").collection("messages").orderBy('timestamp').snapshots();
    }else if(userData.userType == 'STUDENT') {
      return FirebaseFirestore.instance.collection("student_details").doc(auth.currentUser!.uid).collection("chats").doc("${widget.chat.uid!}").collection("messages").orderBy('timestamp').snapshots();
    } else {
      //todo: Add default search log
      return null;
    }
  }

  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();

  Future<void> sendMessage(String text) async {
      try {
        FirebaseFirestore db = FirebaseFirestore.instance;
        FirebaseAuth auth = FirebaseAuth.instance;
        CollectionReference senderMsgRef = db.collection("${Provider.of<UserData>(context, listen: false).userType!.toLowerCase()}_details")
            .doc(auth.currentUser!.uid)
            .collection("chats")
            .doc("${widget.chat.uid!}")
            .collection("messages");
        CollectionReference receiverMsgRef = db.collection("${widget.chat.type!.toLowerCase()}_details")
            .doc(widget.chat.uid!)
            .collection("chats")
            .doc("${auth.currentUser!.uid}")
            .collection("messages");

        try {
          senderMsgRef.doc().set(
            {
              'sender_uid' : auth.currentUser!.uid,
              'timestamp' : FieldValue.serverTimestamp(),
              'text' : text
            }
          ,SetOptions(merge: true) );
        } catch (e) {
          debugPrint("$e");
          debugPrint("Failed to update the sender message ref");
        }

        try {
          receiverMsgRef.doc().set(
              {
                'sender_uid' : auth.currentUser!.uid,
                'timestamp' : FieldValue.serverTimestamp(),
                'text' : text
              }
              ,SetOptions(merge: true) );
        } catch (e) {
          debugPrint("$e");
          debugPrint("Failed to update the receiver message ref");
        }
      } catch (e) {
        debugPrint("$e");
        debugPrint("Failed to send message");
      }
  }

  List<Message> _messages = [];
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: ProfilePic(tutOrStud: widget.chat),
        title: Text(widget.chat.name!)
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (context, snapshot) {

    if(snapshot.hasError) {
      debugPrint("An error occurred");
    }

    if(snapshot.connectionState == ConnectionState.waiting) {
      debugPrint("Waiting for connection");
    }

    if(snapshot.hasData) {

    debugPrint("Got data from firebase");
    ///Load tutor data
    ///Empty searched Tutors
    _messages = [];
    for(DocumentSnapshot messageDoc in snapshot.data!.docs) {
      Message newMsg = Message(messageDoc);
      _messages.add(newMsg);
    }
    }
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                      itemCount: _messages.length + 1,
                      itemBuilder: (context,i) {
                        return (i == _messages.length)
                            ? const SizedBox(
                          height: 50,
                        )
                            :ChatTile(
                          msg: _messages[i].text,
                          isSent: _messages[i].isSent,
                        );
                      }),
                ),
                ///SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: "Type message here",
                    suffixIcon: IconButton(icon: Icon(Icons.send), color: appColor,
                      onPressed: () async{
                      //todo: Add send message function
                        if(_controller.text != null && _controller.text.trim() != "") {
                          await sendMessage(_controller.text);
                          _controller.text = "";
                        }
                        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
                    },)
                  ),
                ),
              ],
            ),
          );
        }
      )
    );
  }
}



