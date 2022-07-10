import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserData extends ChangeNotifier {
  String? _userName;
  String? _userType;
  String? _userId;
  String? _userPhotoPath;
  String? _userPhotoUrl;
  String? _userAge;
  String? _userLevel;
  String? _userPhoneNumber;
  List<String>? _userSubjects = []; //this applies only for the tutors
  String? _userLocation;

  String? get userName => capitalizeFirst(_userName);
  String? get userType => _userType;
  String? get userId => _userId;
  String? get userPhotoPath => _userPhotoPath;
  String? get userPhotoUrl => _userPhotoUrl;
  List<String>? get userSubjects => List<String>.generate(_userSubjects!.length, (i) => capitalizeFirst(_userSubjects![i]) ?? "");
  String? get userLevel => _userLevel;
  String? get userAge => _userAge;
  String? get userPhoneNumber => _userPhoneNumber;
  String? get userLocation => capitalizeFirst(_userLocation);

  set setName (String newName) {
    _userName = newName;
    notifyListeners();
  }
  set setType (String newType) {
    _userType = newType;
    notifyListeners();
  }
  set setId (String newId) {
    _userId = newId;
    notifyListeners();
  }
  set setPhotoPath (String newPhotoPath) {
    _userPhotoPath = newPhotoPath;
    notifyListeners();
  }
  set setPhotoUrl (String newPhotoUrl) {
    _userPhotoUrl = newPhotoUrl;
    notifyListeners();
  }

  void loadUserData(DocumentSnapshot doc) {
    _userName = doc["name"];
    _userType = doc["type"];
    _userId = doc["uid"];
    _userPhotoUrl = doc["photo_url"];
    _userPhoneNumber = doc["phone_number"];
    _userLocation = doc["location"];
    if(_userType == "TUTOR") {
      _userSubjects =[];
      for(dynamic subject in doc["subjects"]) {
        _userSubjects!.add(subject.toString());
      }
    }
    if(_userType == "STUDENT") {
      _userLevel = doc["level"];
    }
    if(_userType == "STUDENT") {
       _userAge = doc["age"];
    }

    notifyListeners();
  }

  String? capitalizeFirst(String? text) {
    if(text == null) return null;
    List<String> textList = text.trim().split(" ");
    List<String> capitalizedTextList = [];
      for(String txt in textList){
      if(txt.length == 1) {
        capitalizedTextList.add(txt.trim()[0].toUpperCase());
        continue; }

        txt.length != 0 ? capitalizedTextList.add(txt.trim()[0].toUpperCase() + txt.trim().substring(1)) : null;
      }
    return capitalizedTextList.join(" ");
  }

}