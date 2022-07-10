import 'package:flutter/material.dart';

class ProfilePic extends StatefulWidget {
  double radius;
  dynamic tutOrStud;
  ProfilePic({this.radius = 40, this.tutOrStud});


  @override
  _StudentTileState createState() => _StudentTileState();
}

class _StudentTileState extends State<ProfilePic> {
  ImageProvider get profilePic => NetworkImage(widget.tutOrStud.photoUrl!);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: CircleAvatar(
          foregroundImage: profilePic,
          radius: 50,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white,),
        ),
    );
  }
}
