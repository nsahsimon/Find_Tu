import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:find_tu/screens/nav_screen.dart';
import 'package:find_tu/screens/login_screen.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:find_tu/data/user_data.dart';
import 'package:find_tu/data/tutors_data.dart';
import 'package:find_tu/data/students_data.dart';

class UserAuth {
  dynamic formKey;
  Function? startLoading;
  Function? stopLoading;
  BuildContext? context;
  UserAuth({this.formKey, this.context, this.startLoading, this.stopLoading});

  static bool noUserFoundForEmail = false;
  static bool wrongPassword = false;
  static bool weakPassword = false;
  static bool accountAlreadyExists = false;
  String? password = "";
  static bool passwordsMatch = true;


  ///segments text into its various components(words) using '|'
  String? removeSpaces(String? text) {
    if(text == null) return null;
    String prevText = '1';
    String currentText = text.trim().toLowerCase().replaceAll(' ','|') + '|';

    while(prevText != currentText){
      prevText = currentText;
      currentText = currentText.replaceAll('||','|');
    }

    currentText = currentText.replaceAll("|", " ");
    print('-----segmented text: $currentText-----');
    return currentText.trim();
  }

  Future<List> getUserData(String? userId) async{
    debugPrint("Getting user data");
    ///retrieve user doc from firebase
    String? userType = "TUTOR";
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("tutor_details").doc(FirebaseAuth.instance.currentUser!.uid).get();
    if(!userDoc.exists){
      userDoc = await FirebaseFirestore.instance.collection("student_details").doc(FirebaseAuth.instance.currentUser!.uid).get();
      if(!userDoc.exists) {
        userType = null;
      }else {
        debugPrint("Successfully retrieve user data from firebase");
        debugPrint("The user is a STUDENT");
        userType = "STUDENT";
      }
    } else {
      debugPrint("Successfully retrieve user data from firebase");
      debugPrint("The user is a TUTOR");
      userType = "TUTOR";
    }
    return [userType,userDoc];
  }

  ///this function takes in '|'(stroke) segmented text as input then outputs ' ' (single space) segmented text
  String? pwdValidation(var value) {

    ///password cannot be empty
    if(value == null || value.isEmpty){
      return "Invalid password";
    }
    ///password cannot contain @
    else if (value.contains('@')) {
      return "Invalid character \"@\" used";
    }
    ///password cannot contain |
    else if (value.contains('|')) {
      return "Invalid character \"|\" used";
    }

    ///password cannot contain spaces
    else if (value.contains(' ')) {
      return 'Password cannot contain empty spaces';
    }

    else return null;
  }

  String? emailValidation(var value){}

  String? confirmPwdValidation(var value) {

    if(value == null || value.isEmpty){
      return "Invalid name";
    }
    else if (passwordsMatch == false) {
      debugPrint("password is : ${password}   while  confirmation password is : ${value}");
      return "Passwords do not match";
    }
    else if (value.contains('@')) {
      return "Invalid char \"@\" used";
    }
    else if (value.contains('|')) {
      return "Invalid character \"|\" used";
    }
    else return null;
  }

  String? usernameValidation(var value) {
    if(value == null || value.isEmpty){
      return "Invalid name";
    }else if (value.length > 20) {
      return "Long name";
    } else if (value.contains('@')) {
      return "Invalid char \"@\" used";
    }else if(accountAlreadyExists) {
      return 'account already exists';
    } else if (value.contains('|')) {
      return "Invalid character \"|\" used";
    } else return null;
  }


  ///Generates sequences of the terms to be searched
  List<String>? genSearchKeys(List<String>? values) {
    if(values == null) return null;
    List<String> searchKeys = [];
    for(String value in values){
      searchKeys = [...searchKeys, ...List<String>.generate((value.length), (i) => value.toLowerCase().substring(0,i+1))];
    }
    return searchKeys;
  }

  String? emailValidationSignUp(var value) {
    if(value == null || value.isEmpty){
      return "Enter a valid email";
    }else if (value.length < 8){
      return "Email is too short";
    }else if(accountAlreadyExists) {
      return 'This email taken. Try another'; //todo: translate
    }
    else return null;
  }

  String? emailValidationLogIn(var value) {
    if(value == null || value.isEmpty){
      return "Please enter a valid email";
    }else if (value.length < 8){
      return "Email too short";
    }else if(value.trim() == ""){
      return "cannot contain empty spaces";
    }else if(noUserFoundForEmail) {
      return 'Wrong email or password'; //todo: translate
    } else return null;
  }

  Future<bool?> login({String? email, String? password, bool isTutor = false}) async{
    this.password = password;
    email = removeSpaces(email);
    FirebaseAuth auth = FirebaseAuth.instance;
    ///if user is already signed in, sign out
    try {
      await auth.signOut();
      debugPrint('-------This user was already signed in-------');
      debugPrint('-------Signing this user out--------');
    }catch(e) {
      debugPrint('------This use is not yet signed in--------;');
    }

    ///check for internet connection
    //if(!(await Dialogs(context:  context).checkConnectionDialog().timeout(Duration(seconds: 3),onTimeout: () => false))) return;
    //todo: check for internet connection

    ///reset all the flags
    noUserFoundForEmail = false;
    wrongPassword = false;

    if(formKey.currentState.validate()) {
      startLoading!();
      debugPrint('--email: ${email}');
      debugPrint('password: ${password}');
      try {
        UserCredential user = await auth.signInWithEmailAndPassword(
            email: email!,
            password: password!).timeout(Duration(seconds: 10));

        if(user != null) {

          try {
            List user = await getUserData(auth.currentUser!.uid);
            stopLoading!();
            String? userType = user[0];
            DocumentSnapshot? userDoc = user[1];
            if(userType != null) {
              ///Load user data
              Provider.of<UserData>(context!, listen: false).loadUserData(userDoc!);
              return true;
            } else {
              return false;
            }
          } catch(e) {
            stopLoading!();
            debugPrint("$e");
            debugPrint("Failed to load user data");
            await signOut();
          }
          stopLoading!();
          return true;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          debugPrint('No user found for that email.');
          ///set flag for wrong email true;
          noUserFoundForEmail = true;
        } else if (e.code == 'wrong-password')
          debugPrint('Wrong password provided for that user.');
        ///set flag for wrong password true
        wrongPassword = true;
      } catch(e) {
        debugPrint("$e");
      }
      stopLoading!();
      formKey.currentState.validate();
    }

  }

  Future<bool> addClientDetails({String? name, String? location, String? phoneNumber, List<String>? subjects, String? photoPath, File? profilePic, String? age, String? level, bool isTutor = false}) async{
    //Checking whether or not the user is a tutor
    isTutor? debugPrint("TUTOR account type was selected") : debugPrint("STUDENT account type was selected");

    //todo: Add client addition logic
    String? profilePicUrl = "";
    bool success = false;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference userRef = isTutor ?  db.collection('tutor_details').doc('${auth.currentUser!.uid}') : db.collection('student_details').doc('${auth.currentUser!.uid}');

    /// Try uploading the profile picture
    if (profilePic != null) {
      try {
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('profile_pics/${auth.currentUser!.uid}');
          UploadTask uploadTask = storageReference.putFile(profilePic!);
          await uploadTask.whenComplete(() async{
            debugPrint('Profile Picture File Uploaded');
            await storageReference.getDownloadURL().then((fileUrl) {
              profilePicUrl = fileUrl;
              debugPrint("profile picture url: $profilePicUrl");
            });
          });

      }catch(e) {
        debugPrint("$e");
        debugPrint("Failed to upload the profile picture");
        return false;
      }
    }


    debugPrint("User Id before writing to document: ${auth.currentUser!.uid}");
    debugPrint(""
        ">>>>>>>>>>>>>>>>>"
        ">>>>>>>>>>>>>>>");
    /// Try adding the user details
    try {
      isTutor ? await userRef.set({
        'name' : name != null ? name.toLowerCase() : "",
        'subjects' : subjects,
        'location' : location != null ? location!.toLowerCase() : "",
        'creation_timestamp' : FieldValue.serverTimestamp(),
        'photo_url' : profilePicUrl,
        'uid' : auth.currentUser!.uid,
        'ratings' : ["0"],
        'type' : "TUTOR",
        'phone_number' : phoneNumber,
        'name_keys': genSearchKeys(["$name"]),
        'subject_keys': genSearchKeys(subjects),
        'location_keys': genSearchKeys(["$location"]),

      }) : await userRef.set({
        'name' : name,
        'age' : age,
        'level' : level,
        'location' : location,
        'creation_timestamp' : FieldValue.serverTimestamp(),
        'photo_url' : profilePicUrl,
        'uid' : auth.currentUser!.uid,
        'type' : "STUDENT",
        'phone_number' : phoneNumber,
        'name_keys': genSearchKeys(["$name"]),
        'location_keys': genSearchKeys(["$location"]),
      });

      success = true;
    }catch (e) {
      debugPrint("$e");
      debugPrint("Failed to add user details");
      success = false;
      // TODO
    }
    stopLoading!();
    return success;
  }

  Future<bool?> signUp({String? email, String? password, String? phoneNumber, String? confirmPassword, String? level, String? name, String? location, List<String>? subjects, String? age, File? profilePic, bool isTutor = false}) async{
    isTutor? debugPrint("(signUp) TUTOR account type was selected") : debugPrint("(signUp) STUDENT account type was selected");

    //this.password = password;
    debugPrint("The password is : ${password}");
    debugPrint("the confirm password is : ${confirmPassword}");
    email = removeSpaces(email);
    name = removeSpaces(name);
    location = removeSpaces(location);
    (password != confirmPassword) ? passwordsMatch = false : passwordsMatch = true;

    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signOut();
      debugPrint('-------This user was already signed in-------');
      debugPrint('-------Signing this user out--------');
    }catch(e) {
      debugPrint('------This user is not yet signed in--------;');
    }

    //reset password
    weakPassword = false;
    accountAlreadyExists = false;

    if(formKey.currentState.validate()) {
      ///resume the loading process since we are done with the formkey.currentState.validate()
      startLoading!();

      if(passwordsMatch) {
        try {
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
              email: email!,
              password: password!
          ).timeout(const Duration(seconds: 15));

          debugPrint("before addingClientDetails user id: ${FirebaseAuth.instance.currentUser!.uid}");
          ///add the client details
          if (await addClientDetails(name: name, location: location , phoneNumber: phoneNumber,subjects: subjects, age: age,profilePic: profilePic, level: level, isTutor: isTutor).timeout(Duration(seconds: 30),onTimeout: () => false)) {
            final SnackBar msg = SnackBar(content: Text('Success'), duration: Duration(seconds: 1)); //todo: translate

            ///check if the user is really signed in
            if(FirebaseAuth.instance.currentUser!.uid != null) {
              try {
                List user = await getUserData(FirebaseAuth.instance.currentUser!.uid);
                stopLoading!();
                String? userType = user[0];
                DocumentSnapshot? userDoc = user[1];
                if(userType != null) {
                  ///Load user data
                  Provider.of<UserData>(context!, listen: false).loadUserData(userDoc!);
                  debugPrint("Successfully loaded user data");
                  stopLoading!();
                  return true;
                } else {
                  debugPrint("Failed to load user data");
                  stopLoading!();
                  return false;
                }
              } catch(e) {
                stopLoading!();
                debugPrint("$e");
                debugPrint("Failed to load user data");
                await FirebaseAuth.instance.currentUser!.delete();
                await signOut();
              }
              stopLoading!();
              return true;
            }
          }

          ///if addition of client details fails, do this
          else {
            //todo: Delete account if unable to add user details
            await FirebaseAuth.instance.currentUser!.delete();
            await signOut(toLogin: false);
            stopLoading!();
            debugPrint("Failed to add client details");
            return false;
          }

        } on FirebaseAuthException catch (e) {
          ///inspecting the various firebase exceptions gotten
          if (e.code == 'weak-password'){
            debugPrint('the password provided is too weak.');

            ///set weak password flag true
            weakPassword = true;}
          else if (e.code == 'email-already-in-use'){
            debugPrint('An account already exists for that email.');

            ///set account already exists flag to true
            accountAlreadyExists = true;
          }

          ///revalidate the form
          stopLoading!();
          formKey.currentState.validate();
        } catch (e) {
          debugPrint("$e");
        }

        var user = FirebaseAuth.instance.currentUser;
        debugPrint('the user is: $user');
        if(user != null) {
          debugPrint(user.email);
          stopLoading!();
          return true;
        } else {
          stopLoading!();
          return false;
        }
      } else {
        stopLoading!();
        formKey.currentState.validate();
        debugPrint('Passwords don\'t match');
      }
    }

  }

  Future<bool> editAccount({String? name, String? location, String? phoneNumber, List<String>? subjects, String? photoPath, File? profilePic, String? age, String? level}) async{
    startLoading!();
    debugPrint("Editing the user account");
    UserData userData = Provider.of(context!, listen: false);
    //todo: Add client addition logic
    bool isTutor = true;
    if(userData.userType == "TUTOR") isTutor = true;
    if(userData.userType == "STUDENT") isTutor = false;

    String? profilePicUrl = userData.userPhotoUrl;
    bool success = false;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference userRef = isTutor ?  db.collection('tutor_details').doc('${auth.currentUser!.uid}') : db.collection('student_details').doc('${auth.currentUser!.uid}');

    /// Update profile picture only if profile pic changed
    if(profilePic != null) {
      try {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_pics/${auth.currentUser!.uid}');
        UploadTask uploadTask = storageReference.putFile(profilePic!);
        await uploadTask.whenComplete(() async{
          debugPrint('Profile Picture File Uploaded');
          await storageReference.getDownloadURL().then((fileUrl) {
            profilePicUrl = fileUrl;
          });
        });

      }catch(e) {
        debugPrint("$e");
        debugPrint("Failed to upload the profile picture");
        stopLoading!();
        return false;
      }
    }

    debugPrint("User Id before writing to document: ${auth.currentUser!.uid}");
    /// Try adding the user details
    try {
      isTutor ? await userRef.set({
        ...(name != userData.userName) ? {'name' : (name != null ? name.toLowerCase() : "")} : <String, dynamic>{},
        ...(location != userData.userLocation) ? {'location' : location != null ? location!.toLowerCase() : ""} : <String, dynamic>{},
        ...(subjects != userData.userSubjects) ? {'subjects' : subjects} : <String, dynamic>{},
        ...{'last_edit_timestamp' : FieldValue.serverTimestamp()},
        ...(profilePicUrl != userData.userPhotoUrl) ? {'photo_url' : profilePicUrl} : <String, dynamic>{},
        ...(phoneNumber != userData.userPhoneNumber) ? {'phone_number' : phoneNumber} : <String, dynamic>{},
        ...(name != userData.userName) ? {'name_keys': genSearchKeys(["$name"])} : <String, dynamic>{},
        ...(subjects != userData.userSubjects) ? {'subject_keys': genSearchKeys(subjects)} : <String, dynamic>{},
        ...(location != userData.userLocation) ? {'location_keys': genSearchKeys(["$location"])} : <String, dynamic>{},
      },
      SetOptions(merge: true)) : await userRef.set({
        ...(name != userData.userName) ? {'name' : (name != null ? name.toLowerCase() : "")} : <String, dynamic>{},
        ...(location != userData.userLocation) ? {'location' : location != null ? location!.toLowerCase() : ""} : <String, dynamic>{},
        ...{'last_edit_timestamp' : FieldValue.serverTimestamp()},
        ...(profilePicUrl != userData.userPhotoUrl) ? {'photo_url' : profilePicUrl} : <String, dynamic>{},
        ...(name != userData.userName) ? {'name_keys': genSearchKeys(["$name"])} : <String, dynamic>{},
        ...(location != userData.userLocation) ? {'location_keys': genSearchKeys(["$location"])} : <String, dynamic>{},
        ...(age != userData.userAge) ? {'age' : age,} : <String, dynamic>{},
        ...(level != userData.userLevel) ? {'level' : level} : <String, dynamic>{},
        ...(location != userData.userLocation) ? {'location' : location} : <String, dynamic>{},
        ...(phoneNumber != userData.userPhoneNumber) ? {'phone_number' : phoneNumber} : <String, dynamic>{},
      },
      SetOptions(merge: true));

      ///update user data
      Future<DocumentSnapshot> userDocFuture = userRef.get();
      DocumentSnapshot userDoc = await userDocFuture;
      userData.loadUserData(userDoc);
      success = true;
    }catch (e) {
      debugPrint("$e");
      debugPrint("Failed to add user details");
      success = false;
      // TODO
    }
    stopLoading!();
    return success;
  }

  Future<void> signOut({bool toLogin = true, bool resetFirstTime = false}) async{
    UserData userData = Provider.of(context!, listen: false);
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signOut();
      resetFirstTime && userData.userType == "TUTOR" ? Provider.of<TutorsData>(context!,listen: false).resetFirstTime() : null;
      resetFirstTime && userData.userType == "STUDENT" ? Provider.of<StudentsData>(context!, listen: false).resetFirstTime() : null;
      toLogin ? Navigator.push(context!, MaterialPageRoute(builder: (context) => LoginScreen())) : null;
      debugPrint(">> The user has signed out");
    } catch(e){
      debugPrint(">> Failed to signout / user_auth.dart");
    }
  }


}

