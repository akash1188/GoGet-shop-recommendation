import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gogetapp/screens/auth/signup.dart';
import 'package:gogetapp/services/fire_auth.dart';
import 'package:gogetapp/widgets/spinner.dart';
import 'package:google_fonts/google_fonts.dart';


class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  late String email, pwd;

  String error = '';

  bool codeSent = false;
  bool loading = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //To Validate email
  String? validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }  
  
  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: HexColor('#2D7A98'),
      //   automaticallyImplyLeading: false,
      //   title: Text('Sign In', style: GoogleFonts.openSans(fontSize: 30.0) ,),centerTitle: true,),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                // height: 100.0,
                // width: 100.0,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage(
                //         'assets/login_signup_screen_logo.png'),
                //     fit: BoxFit.fill,
                //   ),
                //   shape: BoxShape.rectangle,
                // ),
                child: Text('SignIn', style: GoogleFonts.openSans(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black54 )),
              ),
            SizedBox(height: 50.0,),
            Form(key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.alternate_email, color: Colors.orange,),
                      labelText: 'email',
                      labelStyle: GoogleFonts.openSans(color: Colors.green,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(width: 2.0, color: Colors.orange)
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val!.isEmpty ? 'Please provide an email id' : validateEmail(val),
                    onChanged: (val) {
                      setState(() => email = val);
                    }
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key, color: Colors.orange,),
                      labelText: 'password',
                      labelStyle: GoogleFonts.openSans(color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(width: 2.0, color: Colors.black45)
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    validator: (val) => val!.isEmpty ? 'Please provide a password' : null,
                    onChanged: (val) {
                      setState(() => pwd = val);
                    }
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange,),),
                    child: Text('Sign In'),
                    onPressed: () async {
                      if(_formKey.currentState!.validate()){
                        var chkemail = await _firestore.collection('users').where('email', isEqualTo: email).get();
                        if(chkemail.docs.length == 1){ 
                          setState(() => loading = true);
                          dynamic result = await AuthService().signInusingEmailPwd(email, pwd);
                          if (result != null) {
                          setState(() {
                            error = 'Sign-In error. Please retry with correct credentials.';
                            loading = false;
                          });
                          print(error);
                          } 
                        } else {displaySnackBar('You are not yet registered with us.');}
                      }
                    },
                  ),
                  TextButton(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New User?', style: TextStyle(color: Colors.black54),),
                        SizedBox(width: 5.0,),
                        Text('Register', style: TextStyle(color: Colors.orange,),),
                      ],
                    ),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignUp())
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
  displaySnackBar(errtext) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errtext),
        duration: const Duration(seconds: 3),
      ));
  }


}