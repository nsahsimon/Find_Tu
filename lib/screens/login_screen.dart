import 'package:find_tu/data/user_data.dart';
import 'package:flutter/material.dart';
import 'package:find_tu/constants.dart';
import 'package:find_tu/widgets/buttons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:find_tu/widgets/my_text_form_field.dart';
import 'package:find_tu/screens/nav_screen.dart';
import 'package:find_tu/screens/signup_screen.dart';
import 'package:find_tu/processes/user_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:find_tu/widgets/account_type_tile.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  bool isLoading = false;

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

  List<Widget> formChildren (){
    UserAuth userAuth = UserAuth(formKey: formKey, context: context, startLoading: startLoading, stopLoading: stopLoading);

    return [
      Form(
          key: formKey,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                Center(child: Icon(Icons.lock_open_sharp, size: 100, color: appColor)),
                SizedBox(height: 15),
                MyTextFormField(controller: emailController, autoFocus: true, labelText: "E-mail", prefixIcon: Icon(Icons.email_sharp), textInputType: TextInputType.emailAddress, validator: userAuth.emailValidationLogIn,),
                SizedBox(height: 15),
                MyTextFormField(controller: pwdController, labelText: "Password", prefixIcon: Icon(Icons.lock), obscureText: true, validator: userAuth.pwdValidation),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText("Don\"t have an account?", maxLines: 1),
                      TextButton(child: Text("Create one", style: TextStyle(color: appColor)),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                        },)
                    ]
                ),
                SizedBox(height: 25),
              ]
          ) )
    ];
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: SafeArea(
          child: Container(
            child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Center(child: Text("login", style: TextStyle(color: appBarTextColor)))
                ) ,
                body: Center(
                  child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                            children: [
                              ...formChildren(),
                              SizedBox(height: 10),
                              RoundedButton(
                                height: 60,
                                width: 100,
                                text: "Login",
                                onTap: () async {
                                  UserAuth userAuth = UserAuth(formKey: formKey, context: context, startLoading: startLoading, stopLoading: stopLoading);
                                  bool? result = await userAuth.login(email: emailController.text, password: pwdController.text );
                                  if(result == true){
                                    //await showDialog(context: context, builder: (context) => MyDialogs(context: context).success());
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(userType: Provider.of<UserData>(context, listen: false).userType,)));
                                    //todo: push to navigation screen
                                  }
                                  }
                              ),
                              SizedBox(height: 20),
                            ]
                            ),
                      )),
                )
            ),
          ),
        ),
      ),
    );;
  }
}
