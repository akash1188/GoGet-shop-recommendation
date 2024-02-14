import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gogetapp/models/userObjs.dart';

class UserServices {

  final String uid;
  UserServices({ required this.uid });
  var now = new DateTime.now();

  //*********Get user root data from DB
    Stream<UserObjs> get userRootData {
      return FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
      .map(_expUserObjListFromSnapshot);
    }

  // User root data stream
    UserObjs _expUserObjListFromSnapshot(DocumentSnapshot snapshot) {
    
        return UserObjs(
          
          id: snapshot.id,
          uName: (snapshot.data() as dynamic)['usrname'],
          eMail: (snapshot.data() as dynamic)['email'],
          phone: (snapshot.data() as dynamic)['phno'],
          type: (snapshot.data() as dynamic)['type'],
          address: (snapshot.data() as dynamic)['address'],
          lat: (snapshot.data() as dynamic)['lat'],
          long: (snapshot.data() as dynamic)['long']
         
        );

    }

  Future addNewUser(uname, phno, email, address, lat, long, usrtype) async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'usrname' : uname,
      'phno' : phno,
      'email' : email,
      'address' : address,
      'lat' : lat,
      'long' : long,
      'type' : usrtype
    });
  }

  Future addNewStore(uname, phno, email, address, lat, long) async {
    return await FirebaseFirestore.instance.collection('stores').doc(uid).set({
      'storeName' : uname,
      'phno' : phno,
      'email' : email,
      'address' : address,
      'lat' : lat,
      'long' : long,
      'rating' : 0.0,
      'createdDate' : now
    });
  }

}