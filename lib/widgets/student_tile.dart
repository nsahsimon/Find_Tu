import 'package:flutter/material.dart';
import 'package:find_tu/models/student.dart';
import 'package:find_tu/screens/chat_screen.dart';

class StudentTile extends StatefulWidget {
  Student student;
  StudentTile(this.student);


  @override
  _StudentTileState createState() => _StudentTileState();
}

class _StudentTileState extends State<StudentTile> {

  ImageProvider get profilePic => NetworkImage(widget.student.photoUrl!);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        tileColor: Colors.white,
        leading: CircleAvatar(
          foregroundImage: profilePic,
          radius: 40,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white,),
        ),
        title: Text(widget.student.name!),
        subtitle: Text(widget.student.level!),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(widget.student!)));
        },
      ),
    );
  }
}
