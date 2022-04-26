import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchScreen extends SearchDelegate{
  final CollectionReference _collectionReference = FirebaseFirestore.instance.collection('users');
  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        onPressed: (){
          query = '';
        }, 
        icon: const Icon(Icons.close)
    )];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: (){
        Navigator.of(context).pop();
      }, 
      icon: const Icon(Icons.arrow_back)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _collectionReference.snapshots().asBroadcastStream(),
      builder: (context, snapshot){
        if(query == ''){
          return const Text('');
        }
        else if(!snapshot.hasData){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }else if(snapshot.data!.docs.where(
              ( element) => element['displayName']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())).isEmpty){
                return const Center(
                  child: Text('No User Found'),
                );
              }else {
                return ListView(
                children: [
                  ...snapshot.data!.docs.where(
                  ( element) => element['displayName']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())).map((data){
                
                    final String displayName = data['displayName'];
                    final String photoUrl = data['photoUrl'];
                    final DateTime dateOfBirth = (data['dateOfBirth'] as Timestamp).toDate();

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: ClipOval(
                              child: SizedBox(
                                 height: 180,
                                 width: 180,
                                child: Image.network(photoUrl),
                              ),
                            ),
                          ),
                          title: Text(displayName),
                          subtitle: Text(DateFormat.yMMMd().format((dateOfBirth))),
                        ),
                      );
                  })
            ],
          );
        }
      }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Search Users'),
    );
  }
  
}