import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_firebase/screens/signup_screen.dart';
import 'package:user_firebase/shared/constants.dart';
import 'package:user_firebase/shared/loading.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return isloading ? const Loading() : Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
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
                        signIn(emailController.text, passwordController.text);


                        setState(() {
                          isloading = false;
                        });
                      },
                      child: const Text('Login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Don\'t have an account? '),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const SignupScreen()
                          ));
                        },
                        child: const Text('SignUp',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future signIn(String email, String password) async{
    if(_formKey.currentState!.validate()){
      await _auth.signInWithEmailAndPassword(email: email, password: password).then((uid){
        Fluttertoast.showToast(msg: 'Login Successful');
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomeScreen()
        ));

      }).catchError((e){
        Fluttertoast.showToast(msg: e.message);
      });
    }
  }

}