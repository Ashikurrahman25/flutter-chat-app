import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Contact{
  final String id;
  final String email;
  final String image;
  final Timestamp lastSeen;
  final String name;

  Contact({this.id,this.email,this.image,this.lastSeen,this.name});

  factory Contact.fromFirestore(DocumentSnapshot _snapshot){
    var data = _snapshot.data;
    return Contact(
      id: _snapshot.documentID,
      email: data["email"],
      image: data["image"],
      lastSeen: data["lastSeen"],
      name: data["name"],
    );
  }
}