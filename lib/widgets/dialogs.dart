import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_tu/constants.dart';
import 'package:find_tu/models/tutor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';


class Dialogs {
  late BuildContext context;
  Dialogs(this.context);

  double get height => MediaQuery.of(context).size.height;
  double get width => MediaQuery.of(context).size.width;

  Dialog sendTutorshipRequest() {
    return Dialog(
      child: Container(
        height: height * 0.25,
        width: width * 0.7,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AutoSizeText("Would you like to send a tutorship request ?"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton(
                  color: appColor,
                    onPressed: (){
                      Navigator.pop(context, true);
                    },
                    child: Text("Yes", style: TextStyle(color: Colors.white))),
                FlatButton(
                    color: appColor,
                    onPressed: (){
                      Navigator.pop(context, false);
                    },
                    child: Text("No", style: TextStyle(color: Colors.white)))
              ]
            )
          ],
        ),
      )
    );
  }

  Dialog acceptTutorshipRequest(String text) {
    return Dialog(
        child: Container(
          height: height * 0.25,
          width: width * 0.7,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AutoSizeText("$text", textAlign: TextAlign.center,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(
                        color: appColor,
                        onPressed: (){
                          Navigator.pop(context, true);
                        },
                        child: Text("Accept", style: TextStyle(color: Colors.white))),
                    FlatButton(
                        color: appColor,
                        onPressed: (){
                          Navigator.pop(context, false);
                        },
                        child: Text("Decline", style: TextStyle(color: Colors.white)))
                  ]
              )
            ],
          ),
        )
    );
  }

  Dialog rateTutor({double size = 50.0}) {
    int rating = 0;
    return Dialog(
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: height * 0.25,
            width: width * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText("Please rate me..."),
                Row(
                  children: [
                    ...List<IconButton>.generate(5, (i) {
                      return (i <= rating - 1)
                          ? IconButton(icon: Icon(Icons.star, color: Colors.orangeAccent, size: size),
                        onPressed: () {
                          setState((){
                            rating = i + 1;
                          });
                        },)
                          : IconButton(icon: Icon(Icons.star_border, color: Colors.grey, size: size),
                          onPressed: () {
                            setState((){
                              rating = i + 1;
                            });
                          });
                    })
                  ],
                ),
                FlatButton(
                    color: appColor,
                    onPressed: (){
                      Navigator.pop(context, rating);
                    },
                    child: Text("Ok", style: TextStyle(color: Colors.white)))
              ],
            ),
          );
        }
      ),
    );
  }

  Dialog showTutorDetails(Tutor tutor) {
    return Dialog(
      child: Container(
        width: width * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(70),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                height: 10
            ),
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey,
                foregroundImage: NetworkImage(tutor.photoUrl?? ""),
                child: Center(child: Icon(Icons.person, color: Colors.white, size: 120 ))
              )
            ),
            SizedBox(
              height: 10
            ),
            AutoSizeText(
              "Hello, my name is ${tutor.name!.toUpperCase()}. I teach ${tutor.subjectList.toUpperCase()} and I live "
                  "in ${tutor.location}. Please send me a tutorship request if you need my help. Thanks",
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            FlatButton(
              color: appColor,
              child: AutoSizeText("send request", style: TextStyle(color: Colors.white)) ,
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            SizedBox(height: 20),


          ]
        ),
      )
    );
  }
}

