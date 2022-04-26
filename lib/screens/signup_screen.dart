import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_firebase/screens/profile_screen.dart';

import '../model/user_model.dart';
import '../shared/constants.dart';
import '../shared/loading.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key,}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return isloading ? const Loading() :Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back,
            color: Colors.red,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Form(
              key: _formKey,
              child: Column(
                children:[
                  const SizedBox(height: 20.0,),
                  TextFormField(
                    decoration: textInputDecorationEmail,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                    onChanged: (value) {
                      setState(() {
                        emailController.text = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0,),
                  TextFormField(
                    decoration: textInputDecorationPassword,
                    validator: (value) => value!.length < 6 ? 'Enter a password 6+ chars long' : null,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        passwordController.text = value;
                      });
                    },
                  ),
                  const SizedBox(height: 30.0,),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.red,
                    child: MaterialButton(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      minWidth: MediaQuery.of(context).size.width,
                      onPressed: (){
                        setState(() {
                          isloading = true;
                        });
                        signUp(emailController.text, passwordController.text);

                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                            builder: (context) => const ProfileScreen()),
                                (route) => false);
                        setState(() {
                          isloading = false;
                        });
                      },
                      child: const Text('Signup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

   Future signUp(String email, String password) async{
    if(_formKey.currentState!.validate()){
      await _auth.createUserWithEmailAndPassword(email: email, password: password).then((uid){
      uploadingData();
      }).catchError((e){
        Fluttertoast.showToast(msg: e.message);
      });
    }
  }

  uploadingData() async{
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.photoUrl = user.photoURL;
    userModel.displayName = user.displayName;

    await firebaseFirestore.collection('users').doc(user.uid).set(userModel.toMap());
    Fluttertoast.showToast(msg: 'Account Created Successfully');
  }

}