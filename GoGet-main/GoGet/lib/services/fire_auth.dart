import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogetapp/screens/auth/signin.dart';
import 'package:gogetapp/services/fire_users.dart';
import 'package:gogetapp/widgets/wrapper.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  handleAuth() {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return Wrapper();
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SignIn()
          );
        }
      }
    );
  }

  // sign in with email/ pwd 
  Future signInusingEmailPwd(String email, String pwd) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: pwd);
      User? user = result.user;
      print('signed-in successfully!!');
      print(user!.uid);
      // return user.uid;
    }catch(e) {
      print(e.toString());
      print('login error please retry');
      return e;
    }
  }

 // register with email/ pwd 
  Future signUpusingEmailPwd(uname, phno, email, pwd, address, lat, long, usrtype) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: pwd);
        User? user = result.user;
        
        // create a new user with uid
        await UserServices(uid: user!.uid).addNewUser(uname, phno, email, address, lat, long, usrtype);
        if (usrtype == 'Shop'){
          await UserServices(uid: user.uid).addNewStore(uname, phno, email, address, lat, long);
        }
      // return user.uid;
      }catch(e) {
        print(e.toString());
        print('reached signup error.. returning NULL');
        return e;
      }
    }
  // sign out
  Future<void> signOut() async {
    try {

      await FirebaseAuth.instance.signOut();
      
    }catch(e) {
      print(e.toString());
      return null;
    }
  }
}