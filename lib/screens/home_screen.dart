import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_firebase/model/user_model.dart';
import 'package:user_firebase/screens/profile_page.dart';
import 'package:user_firebase/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((value){
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot){
          return !snapshot.hasData ? const Center(child: CircularProgressIndicator())
          :ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index){
              DocumentSnapshot users = snapshot.data!.docs[index];
              final String displayName = users['displayName'];
              final String photoUrl = users['photoUrl'];
              final DateTime dateOfBirth = (users['dateOfBirth'] as Timestamp).toDate();
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    child: ClipOval(
                      child: SizedBox(
                        height: 180,
                        width: 180,
                        child: Image.network(photoUrl)
                      )
                    ),
                  ),
                  title: Text(displayName),
                  subtitle: Text(DateFormat.yMMMd().format((dateOfBirth))),
                ),
              );
            }
          );
        },
      )
    );
  }

  _appBar() {
    final appBarHeight = AppBar().preferredSize.height;
    return PreferredSize(
      child: AppBar(
        elevation: 0,
        title:Text('${loggedInUser.displayName}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => showSearch(context: context, delegate: SearchScreen()),
        ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const ProfilePage()
              ));
            }, 
            icon: const Icon(Icons.person),
          ),
        ],
      ), 
      preferredSize: Size.fromHeight(appBarHeight)
    );
  }
}