import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_tu/widgets/my_text_form_field.dart';
import 'package:find_tu/widgets/buttons.dart';
import 'package:find_tu/processes/user_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:find_tu/screens/nav_screen.dart';
import 'package:find_tu/widgets/account_type_tile.dart';
import 'package:find_tu/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:find_tu/data/user_data.dart';

class EditingAccountScreen extends StatefulWidget {
  @override
  _EditingAccountScreenState createState() => _EditingAccountScreenState();
}

class _EditingAccountScreenState extends State<EditingAccountScreen> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<AccountTypeTileState> accountTypeKey = GlobalKey<AccountTypeTileState>();
  bool infoLoaded = false;


  TextEditingController nameController = TextEditingController(text: null);
  TextEditingController locationController = TextEditingController(text: null);
  TextEditingController levelController = TextEditingController(text: null);
  TextEditingController subjectController = TextEditingController(text: null);
  TextEditingController ageController = TextEditingController(text: null);
  TextEditingController phoneNumberController = TextEditingController(text: null);
  TextEditingController profilePicPathController = TextEditingController(text: null);


  bool isLoading = false;
  File? profilePic;

  void startLoading(){
    setState((){
      isLoading = true;
    });
  }

  void stopLoading(){
    setState((){
      isLoading = false;
    });
  }


  Future<void> getProfilePic() async{
    try {
      XFile? profilePicXfile = await ImagePicker().pickImage(source: ImageSource.gallery);
      setState((){
        profilePic = File(profilePicXfile!.path);
      });
      profilePicPathController.text = profilePic!.path;
    }catch(e) {
      debugPrint("Failed to get the profile picture");
    }

  }


  List<Widget> formChildren (BuildContext context){
    UserAuth userAuth = UserAuth(formKey: formKey, context: context, startLoading: startLoading, stopLoading: stopLoading);
    UserData userData = Provider.of<UserData>(context, listen: false);
    bool isTutor() {
      if(userData.userType == "TUTOR") return true;
      else if(userData.userType == "STUDENT") return false;
      else return true;
    }

    if(infoLoaded == false) {
      ///load info
         nameController.text = userData.userName ?? "";
         locationController.text = userData.userLocation ?? "";
         levelController.text = userData.userLevel ?? "";
         subjectController.text = userData.userSubjects == null ? "" : userData.userSubjects!.join(",");
         ageController.text = userData.userAge ?? "";
         phoneNumberController.text = userData.userPhoneNumber ?? "";
         profilePicPathController.text = userData.userPhotoUrl ?? "";
        infoLoaded = true;
    }

    return [
      Form(
          key: formKey,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                GestureDetector(
                  onTap: getProfilePic,
                  child: Center(
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey,
                      backgroundImage: (profilePic == null) ? NetworkImage("${userData.userPhotoUrl}") : null,
                      foregroundImage: (profilePic == null) ? null : FileImage(profilePic!),
                    )
                  ),
                ),
                SizedBox(height: 15),
                MyTextFormField(controller: nameController, hintText: userData.userName, autoFocus: true, labelText: "Change name", prefixIcon: Icon(Icons.person),
                    textInputType: TextInputType.emailAddress,validator: userAuth.usernameValidation ),
                SizedBox(height: 15),
                MyTextFormField(controller: phoneNumberController,  hintText: userData.userPhoneNumber, textInputType: TextInputType.number ,labelText: "Change phone number", prefixIcon: Icon(Icons.phone)),
                SizedBox(height: 15),
                MyTextFormField(controller: locationController, hintText: userData.userLocation, labelText: "Change location", prefixIcon: Icon(Icons.location_on)),
                SizedBox(height: 15),
                !isTutor() ? MyTextFormField(controller: levelController, hintText: userData.userLevel, labelText: "Change your class", prefixIcon: Icon(Icons.grade_sharp)) : Container(child: null),
                SizedBox(height: 15),
                isTutor() ? MyTextFormField(controller: subjectController, hintText: userData.userSubjects!.join(","), labelText: "Which subjects do you teach now?", prefixIcon: Icon(Icons.menu_book_rounded)) : Container(child: null),
                SizedBox(height: 15),
                MyTextFormField(controller: profilePicPathController, readOnly: true,  labelText: "Change profile picture (<1MB)", prefixIcon: Icon(Icons.photo_library), suffixIconButton: IconButton(icon: Icon(Icons.arrow_forward_ios_outlined), onPressed: getProfilePic),),
                SizedBox(height: 25),
              ]
          ) )
    ];
  }

  @override
  Widget build(BuildContext context) {

    return ModalProgressHUD(
        inAsyncCall: isLoading,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text("Account", style: TextStyle(color: appBarTextColor)),
            ) ,
            body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                      children: [
                        ...formChildren(context),
                        SizedBox(height: 10),
                        RoundedButton(
                            height: 60,
                            width: 150,
                            text: "Edit Account",
                            onTap: () async{


                              UserAuth userAuth = UserAuth(formKey: formKey, context: context, startLoading: startLoading, stopLoading: stopLoading);
                              bool? result = await userAuth.editAccount(
                                name: nameController.text,
                                location: locationController.text ,
                                subjects: [subjectController.text],
                                profilePic: profilePic,
                                age: ageController.text ?? "0",
                                level: levelController.text,
                                phoneNumber: phoneNumberController.text,
                              );
                              if(result == true){
                                debugPrint("Account successfully edited");
                                //await showDialog(context: context, builder: (context) => MyDialogs(context: context).success());
                                Navigator.pop(context);
                              }
                            }
                        ),
                        SizedBox(height: 20),

                      ]
                  ),
                )
            ),
          ),
        ));
  }
}
