import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:user_firebase/model/user_model.dart';
import 'package:user_firebase/shared/loading.dart';
import 'home_screen.dart';
import 'login_screen.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final TextEditingController displayNameController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  bool isloading = false;
  DateTime? selectedDate;
  UserModel loggedInUser = UserModel();


  File? _image;
  String? downloadUrl;
  final imagePicker = ImagePicker();
  Future getImage() async{
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if(pick != null){
        _image = File(pick.path);
      }
      else{
        Exception;
      }
    });
  }

  Future uploadData() async{
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('${user!.email}/image').child('post');
    await ref.putFile(_image!);
    downloadUrl = await ref.getDownloadURL();

    await firebaseFirestore.collection('users').doc(user!.uid).update({
      'displayName': displayNameController.text,
      'dateOfBirth': selectedDate,
      'photoUrl': downloadUrl,
    }).catchError((e){
      if (kDebugMode) {
        print(e);
      }
    });

  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('users')
        .doc(user!.uid).get().then((value){
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return isloading ? const Loading() : Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              logOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                    child: CircleAvatar(
                      radius: 70,
                      child: ClipOval(
                          child: SizedBox(
                              width: 180,
                              height: 180,
                              child: _image != null
                                  ? Image.file(_image!, fit: BoxFit.fill,)
                                  : Image.network(
                                  '${loggedInUser.photoUrl}')
                          )
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        getImage();
                      },
                      icon: const Icon(Icons.photo_camera)
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  hintText: '${loggedInUser.displayName}',
                  prefixIcon: const Icon(Icons.person),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                value!.isEmpty
                    ? 'Enter Display Name'
                    : null,
                onChanged: (value) {
                  setState(() {
                    displayNameController.text = value;
                  });
                },
              ),
              const SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  hintText: selectedDate == null
                      ? '${loggedInUser.dateOfBirth}'
                      : DateFormat.yMMMd()
                      .format(selectedDate!),
                  prefixIcon: IconButton(
                    onPressed: () {
                      selectDate(context);
                    },
                    icon: const Icon(Icons.calendar_month),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Enter DateOfBirth' : null,
                onChanged: (value) {
                  setState(() {
                    selectedDate = value as DateTime?;
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
                  minWidth: MediaQuery
                      .of(context)
                      .size
                      .width,
                  onPressed: () async {
                    setState(() {
                      isloading = true;
                    });
                    await uploadData();
                    setState(() {
                      isloading = false;
                    });

                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (context) => const HomeScreen()),
                            (route) => false);

                  },
                  child: const Text('Update',
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
    );
  }

  Future<void> logOut() async{
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginScreen()
    ));
  }

  Future selectDate(BuildContext context) async{
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1950);
    DateTime lastDate = DateTime(2050);

    final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate
    );

    if(date != null){
      setState(() {
        selectedDate = date;
      });
    }
  }
}
