import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogetapp/models/userObjs.dart';
import 'package:gogetapp/screens/grocery/grocery_home.dart';
import 'package:gogetapp/screens/shopper/shopper_home.dart';
import 'package:gogetapp/services/fire_users.dart';
import 'package:gogetapp/widgets/spinner.dart';


class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    
    User? user = FirebaseAuth.instance.currentUser;
    
      return StreamBuilder<UserObjs>(
      stream: UserServices(uid: user!.uid).userRootData,
      builder: (context,snapshot){
        UserObjs? userObjs = snapshot.data;
        if (snapshot.hasData){
          var usrType = userObjs!.type;
          if (usrType == 'Shop'){
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: ShopHome(),
            );
          } else if (usrType == 'Shopper'){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: ShopperHome(),
            );
          }
        }
        return Loading();
      }
    );
  }
}

