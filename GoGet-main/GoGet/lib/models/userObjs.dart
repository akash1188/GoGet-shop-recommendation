import 'package:firebase_auth/firebase_auth.dart';

User? user = FirebaseAuth.instance.currentUser;

class UserObjs {

  String id;
  String uName;
  String eMail;
  String phone;
  String type;
  String address;
  String lat;
  String long;
 

  UserObjs({ required this.id, required this.uName, required this.eMail, required this.phone, required this.address, required this.lat, required this.long, required this.type });
}

