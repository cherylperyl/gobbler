import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/model/app_state_model.dart';
import 'package:mobile/model/user_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    showPassword = false;
    errorMessage = '';
    isLoading = false;
  }
  
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child){
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(),
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: ListView(
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Gobbler',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 30),
                      )),
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 20),
                      )),
                  isLoading 
                  ? const Center(child: CupertinoActivityIndicator(),)
                  : Container(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Center(
                      child: Text(errorMessage, 
                      style: TextStyle(color: CupertinoColors.systemRed),)
                    ),
                  ),
                  CupertinoTextFormFieldRow(
                    validator: (value) {
                      if (value == '') {
                        return "Please enter a username";
                      } else {
                        return null;
                      }
                    },
                    padding: EdgeInsets.symmetric(horizontal: 2, ),
                    controller: usernameController,
                    textInputAction: TextInputAction.next,
                    placeholder: "Username",
                    decoration: BoxDecoration(
                      color: CupertinoColors.extraLightBackgroundGray,
                      border: Border.all(
                        color: CupertinoColors.lightBackgroundGray,
                        width:2
                      ),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    cursorColor: CupertinoColors.activeGreen,
                  ),
                  SizedBox(height: 30),
                  CupertinoTextFormFieldRow(
                    validator: (value) {
                      RegExp regex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                      if (value == '') {
                        return "Please enter your email";
                      } else if (!regex.hasMatch(value!)) {
                        return "Please enter a valid email";
                      } 
                      else {
                        return null;
                      }
                    },
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    placeholder: "Email",
                    decoration: BoxDecoration(
                      color: CupertinoColors.extraLightBackgroundGray,
                      border: Border.all(
                        color: CupertinoColors.lightBackgroundGray,
                        width:2
                      ),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    cursorColor: CupertinoColors.activeGreen,
                  ),
                  SizedBox(height: 30),
                  CupertinoTextFormFieldRow(
                    validator: (value) {
                      RegExp regex = RegExp(r'(?=.*?[0-9])(?=.*?[A-Za-z]).+');
                      if (value == '') {
                        return "Please enter password";
                      } 
                      else if (value!.length < 6) {
                        return "Please use at least 6 characters";
                      }
                      else if (!regex.hasMatch(value!)) {
                        return "Please include one character and one number";
                      }
                      return null;
                    },
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    placeholder: "Password",
                    obscureText: !showPassword,
                    controller: passwordController,
                    decoration: BoxDecoration(
                      color: CupertinoColors.extraLightBackgroundGray,
                      border: Border.all(
                        color: CupertinoColors.lightBackgroundGray,
                        width:2
                      ),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    cursorColor: CupertinoColors.activeGreen,
                  ),
                  CupertinoButton(
                        child: showPassword ?
                        Icon(CupertinoIcons.eye_slash_fill)
                        : Icon(CupertinoIcons.eye_fill)
                        ,
                          onPressed: () {setState(() {showPassword = !showPassword;});},
                        ),
                  CupertinoButton.filled(
                    child: const Text('Register'),
                    onPressed: () async {
                      formKey.currentState!.save();
                      setState(() {isLoading=true;});
                      if (formKey.currentState!.validate()) {
                        try {
                          await model.signupUser(usernameController.text, emailController.text, passwordController.text);
                          setState((){errorMessage='';});
                          Fluttertoast.showToast(
                            msg: "Registered succesfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 2,
                            backgroundColor: CupertinoColors.activeGreen,
                            textColor: Colors.white,
                            fontSize: 16.0
                          );
                          Navigator.of(context).pop();
                        } catch(err) {
                          if (err.toString() == 'Connection timed out') {
                            setState(() { errorMessage = 'Please check your internet connection';});
                          } else {
                            print(err.toString());
                            setState(() { errorMessage = 'Please check your internet connection';});
                          }
                        }
                      }
                      setState((){isLoading=false;});
                    },
                  ),
                  Row(
                    children: <Widget>[
                      const Text("Already have an account?"),
                      CupertinoButton(
                        child: const Text(
                          'Login',
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ],
              )),
          ),
        );
      }
    );
    
  }
}