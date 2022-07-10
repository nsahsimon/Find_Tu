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

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<AccountTypeTileState> accountTypeKey = GlobalKey<AccountTypeTileState>();
  bool isTutor = false;
  void toggleIsTutor() {
    setState((){
      isTutor = !isTutor;
    });
  }


  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController confirmPwdController = TextEditingController();
  TextEditingController locationController = TextEditingController(text: "");
  TextEditingController levelController = TextEditingController(text: "");
  TextEditingController subjectController = TextEditingController(text: "");
  TextEditingController ageController = TextEditingController(text: "");
  TextEditingController phoneNumberController = TextEditingController(text: "");
  TextEditingController profilePicPathController = TextEditingController(text: "");


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
      profilePic = File(profilePicXfile!.path);
      profilePicPathController.text = profilePic!.path;
    }catch(e) {
      debugPrint("Failed to get the profile picture");
    }

  }


  List<Widget> formChildren (BuildContext context){
    UserAuth userAuth = UserAuth(formKey: formKey, context: context, startLoading: startLoading, stopLoading: stopLoading);
    return [
      Form(
          key: formKey,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                AccountTypeTile(toggleIsTutor),
                SizedBox(height: 15),
                MyTextFormField(controller: nameController, autoFocus: true, labelText: "Enter your name", prefixIcon: Icon(Icons.person),
                    textInputType: TextInputType.emailAddress, validator: userAuth.usernameValidation ),
                SizedBox(height: 15),
                MyTextFormField(controller: emailController, labelText: "Enter E-mail", prefixIcon: Icon(Icons.email_sharp),
                    textInputType: TextInputType.emailAddress, validator: userAuth.emailValidationSignUp ),
                !isTutor ? SizedBox(height: 15) : Container(child: null),
                !isTutor ? MyTextFormField(controller: ageController, labelText: "How old are you", prefixIcon: Icon(Icons.calendar_today),
                    textInputType: TextInputType.number) : Container(child: null),
                SizedBox(height: 15),
                MyTextFormField(controller: phoneNumberController, textInputType: TextInputType.number ,labelText: "Enter your phone number?", prefixIcon: Icon(Icons.phone)),
                SizedBox(height: 15),
                MyTextFormField(controller: pwdController, labelText: "Enter Password", prefixIcon: Icon(Icons.lock),
                    obscureText: true, validator: userAuth.pwdValidation),
                SizedBox(height: 15),
                MyTextFormField(controller: confirmPwdController, labelText: "Re-enter Password", prefixIcon: Icon(Icons.lock),
                    obscureText: true, validator: userAuth.confirmPwdValidation),
                SizedBox(height: 15),
                MyTextFormField(controller: locationController, labelText: "Where do you live?", prefixIcon: Icon(Icons.location_on)),
                SizedBox(height: 15),
                !isTutor ? MyTextFormField(controller: levelController, labelText: "In which class are you?", prefixIcon: Icon(Icons.grade_sharp)) : Container(child: null),
                SizedBox(height: 15),
                isTutor ? MyTextFormField(controller: subjectController, labelText: "Which subject do you teach?", prefixIcon: Icon(Icons.menu_book_rounded)) : Container(child: null),
                SizedBox(height: 15),
                MyTextFormField(controller: profilePicPathController, readOnly: true, labelText: "Choose a profile picture (<1MB)", prefixIcon: Icon(Icons.photo_library), suffixIconButton: IconButton(icon: Icon(Icons.arrow_forward_ios_outlined), onPressed: getProfilePic),),
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
              title: Text("Sign-Up", style: TextStyle(color: appBarTextColor)),
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
                        text: "Register",
                        onTap: () async{
                          UserAuth userAuth = UserAuth(formKey: formKey, context: context, startLoading: startLoading, stopLoading: stopLoading);
                          bool? result = await userAuth.signUp(
                            email: emailController.text,
                            password: pwdController.text,
                            confirmPassword: confirmPwdController.text,
                            name: nameController.text,
                            location: locationController.text,
                            subjects: [subjectController.text],
                            isTutor: isTutor,
                            profilePic: profilePic,
                            age: ageController.text ?? "0",
                            level: levelController.text,
                            phoneNumber: phoneNumberController.text,
                          );
                          if(result == true){
                            debugPrint("account successfully created: transitioning to the next screen");
                            //await showDialog(context: context, builder: (context) => MyDialogs(context: context).success());
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(userType: Provider.of<UserData>(context, listen: false).userType,)));
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
