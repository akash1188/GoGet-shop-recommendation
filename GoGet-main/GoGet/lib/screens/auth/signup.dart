import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gogetapp/screens/auth/signin.dart';
import 'package:gogetapp/services/fire_auth.dart';
import 'package:flutter/services.dart';
import 'package:gogetapp/widgets/spinner.dart';
import 'package:google_fonts/google_fonts.dart';


class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  
  late String phoneNo, uname, email, lat, long, usrType, pwd;
  String address = '';

  int isSelected = 1;

  bool toggleval = false;
  bool loading = false;

  late final Position _currentPosition;
  late String _currentAddress = 'Auto detecting location ...';

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
  void initState() {
    super.initState();
    getCurrPosition();
  }
  
  @override
  Widget build(BuildContext context) {    

    return loading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: true,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.orange,
      //   title: Text('Register', style: GoogleFonts.openSans(fontSize: 30.0) ,),
      //   centerTitle: true,),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 80.0, horizontal: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  child: Text('SignUp', style: GoogleFonts.openSans(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black54 )),
                ),
                SizedBox(height: 50.0,),
              Form(key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.account_circle_sharp, color: Colors.orange, size: 28.0,),
                        labelText: 'Name',
                        labelStyle: GoogleFonts.openSans(color: Colors.black54,),
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
                      //obscureText: true,
                      validator: (val) => val!.isEmpty ? 'Please provide your first and last name' : null,
                      onChanged: (val) {
                        setState(() => uname = val);
                      }
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.alternate_email, color: Colors.orange,),
                        labelText: 'email',
                        labelStyle: GoogleFonts.openSans(color: Colors.black54,),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0),),
                          borderSide: BorderSide(color: Colors.grey)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0),),
                          borderSide: BorderSide(width: 2.0, color: Colors.black45)
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      //obscureText: true,
                      validator: (val) => val!.isEmpty ? 'Please provide an email id' : validateEmail(val),
                      onChanged: (val) {
                        setState(() => email = val);
                      }
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.vpn_key, color: Colors.orange,),
                        labelText: 'password',
                        labelStyle: GoogleFonts.openSans(color: Colors.black54,),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0),),
                          borderSide: BorderSide(color: Colors.grey)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0),),
                          borderSide: BorderSide(width: 2.0, color: Colors.black45)
                        ),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      validator: (val) => val!.isEmpty ? 'Password cannot be blank' : null,
                      onChanged: (val) {
                        setState(() => pwd = val);
                      }
                    ),
                    SizedBox(height: 20,),
                    TextFormField(
                      onTap: (){ getCurrPosition(); },
                      decoration: InputDecoration(
                        enabled: true,
                        prefixIcon: Icon(Icons.location_on, color: Colors.orange,),
                        // ignore: unnecessary_null_comparison
                        labelText: _currentAddress,
                        labelStyle: GoogleFonts.openSans(color: Colors.black54,),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0),),
                          borderSide: BorderSide(color: Colors.grey)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0),),
                          borderSide: BorderSide(width: 2.0, color: Colors.black45)
                        ),
                      ),
                      //maxLength: 10,
                      keyboardType: TextInputType.streetAddress,
                      // validator: (val) => val!.isEmpty ? 'Address cannot be empty. Please set your current location.' : null,
                      onChanged: (val) {
                        setState(() => address = val);
                      }
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone, color: Colors.orange,),
                        labelText: 'mobile number',
                        labelStyle: GoogleFonts.openSans(color: Colors.black54,),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0),),
                          borderSide: BorderSide(color: Colors.grey)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0),),
                          borderSide: BorderSide(width: 2.0, color: Colors.black45)
                        ),
                      ),
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      validator: (val) => val!.isEmpty ? 'Please provide a valid mobile number to login' : null,
                      onChanged: (val) {
                        setState(() => phoneNo = val);
                      }
                    ),
                    SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('SHOPPER'),
                        SizedBox(width: 15.0,),
                        (Switch(inactiveThumbColor: Colors.orange, inactiveTrackColor: Colors.amber, activeTrackColor: Colors.greenAccent, activeColor: Colors.green, value: toggleval, onChanged: (val) {setState(() { toggleval = val;});})),
                        SizedBox(width: 15.0,),
                        Text('SHOP OWNER'),
                      ],
                    ),
                    SizedBox(height: 20),
                    // ignore: unnecessary_null_comparison
                  //   userLocation == null
                  // ? CircularProgressIndicator()
                  // : Text("Location:" +
                  //     userLocation.latitude.toString() +
                  //     " " +
                  //     userLocation.longitude.toString()),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange,),),
                      child: Text('Register'),
                      onPressed: () async {
                        
                        if(_formKey.currentState!.validate()){
                          var chkphno = await _firestore.collection('users').where('phno', isEqualTo: '+91 '+phoneNo).get();
                          var chkemail = await _firestore.collection('users').where('email', isEqualTo: email).get();
                          if(chkphno.docs.length == 0 && chkemail.docs.length == 0){   
                            setState(() {
                              loading = true;
                            });
                            if (toggleval == false) {usrType = 'Shopper';} else {usrType = 'Shop';}
                            var inPhoneNo = '+91 '+ phoneNo.trim();
                            var add = address == '' ? _currentAddress : address;
                            var result = await AuthService().signUpusingEmailPwd(uname, inPhoneNo, email, pwd, add, lat, long, usrType);
                            if (result != null){displaySnackBar(result.toString());}
                            } else {
                              displaySnackBar('Provided values already exist in our database, please see if you can sign-in directly.');
                            }
                            setState(() {
                              loading = false;
                            });
                          }else {displaySnackBar('All fields are mandatory');}
                        } 
                       
                      
                    ),
                    TextButton(
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Registered already?', style: TextStyle(color: Colors.black54),),
                          SizedBox(width: 5.0,),
                          Text('Sign In', style: TextStyle(color: Colors.orange,),),
                        ],
                      ),
                      onPressed: () async {
                        await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SignIn())
                        );
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
  // Future<void> verifyPhone(phoneNo) async {
    
  //   final PhoneVerificationCompleted verified = (AuthCredential authResult) {
  //     _auth.signIn(authResult);
  //   };

  //   final PhoneVerificationFailed verificationfailed =
  //       (FirebaseAuthException authException) {
  //     //print('${authException.message}');
  //     displaySnackBar('Validation error, please try again later');
  //   };

  //   final void Function(String verId, [int? forceResend]) smsSent = (String verId, [int? forceResend]) async {
  //     this.verificationId = verId;
  //     if (address == '') { address = _currentAddress;}
  //     await Navigator.of(context).push(
  //                     MaterialPageRoute(builder: (context) => OTP(verId, 'signup', uname, phoneNo, email, address, lat, long, usrType)));           
  //   };

  //   final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
  //     this.verificationId = verId;
  //   };

  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: phoneNo,
  //       //timeout: const Duration(seconds: 5),
  //       verificationCompleted: verified,
  //       verificationFailed: verificationfailed,
  //       codeSent: smsSent,
  //       codeAutoRetrievalTimeout: autoTimeout);
  // }

  displaySnackBar(errtext) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errtext),
        duration: const Duration(seconds: 5),
      ));
  }

  getCurrPosition() async {
    // CHECK IF LOCATION SETTING IS ON
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // CHECK IF APP HAS PERMISSION TO GET LOCATION
    var permission = await Geolocator.checkPermission();

    if ((!serviceEnabled) || (permission == LocationPermission.denied) || (permission == LocationPermission.deniedForever))
    {displaySnackBar('This app uses Location services and will not work properly if not enabled.');}

    Geolocator
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
      .then((Position position) {
    setState(() {
      _currentPosition = position;
      lat = _currentPosition.latitude.toString();
      long = _currentPosition.longitude.toString();
    });
    print(_currentPosition.latitude);
    print(_currentPosition.longitude);
    _getAddressFromLatLng();
  }).catchError((e) {
    print(e);
  });
  }

  _getAddressFromLatLng() async {
  try {
    List<Placemark> p = await GeocodingPlatform.instance.placemarkFromCoordinates(
        _currentPosition.latitude, _currentPosition.longitude);
    Placemark place = p[0];
    setState(() {
      _currentAddress =
      "${place.locality}, ${place.postalCode}, ${place.country}";
    });
  } catch (e) {
    print(e);
  }
}

}