// import 'package:flutter/material.dart';
// import 'package:gogetapp/services/fire_auth.dart';
// import 'package:gogetapp/widgets/spinner.dart';
// import 'package:google_fonts/google_fonts.dart';


// class OTP extends StatefulWidget {
//   @override
//   _OTPState createState() => _OTPState();

//   final verID;
//   final String type, uname, phno, email, address, lat, long, usrtype;

//   OTP(this.verID, this.type, this.uname, this.phno, this.email, this.address, this.lat, this.long, this.usrtype);
// }

// class _OTPState extends State<OTP> {

//   final _formKey = GlobalKey<FormState>();
  
//   late String otpkey, verificationId;
  
//   String error = '';

//   bool codeSent = false;
//   bool loading = false;
  
//   @override
//   Widget build(BuildContext context) {
//     return loading ? Loading() : Scaffold(
//       // appBar: AppBar(
//       //   automaticallyImplyLeading: false,
//       //   backgroundColor: Colors.orange,
//       //   title: Text('Enter OTP', style: GoogleFonts.openSans(fontSize: 30.0) ,),
//       //   centerTitle: true,),
//       body: Container(
//         padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Form(key: _formKey,
//               child: Column(
//                 children: [
//               SizedBox(height: 50.0,),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       prefixIcon: Icon(Icons.vpn_key, color: Colors.orange,),
//                       labelText: 'Enter OTP',
//                       labelStyle: GoogleFonts.openSans(color: Colors.black54),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(25.0),),
//                         borderSide: BorderSide(color: Colors.grey)
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(25.0),),
//                         borderSide: BorderSide(width: 2.0, color: Colors.black45)
//                       ),
//                     ),
//                     keyboardType: TextInputType.phone,
//                     validator: (val) => val!.isEmpty ? 'Please enter OTP received via SMS' : null,
//                     onChanged: (val) {
//                       setState(() => otpkey = val);
//                     }
//                   ),
//                   Text('$error', style: TextStyle(color: Colors.red)),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange),),
//                     child: Text('Confirm'),
//                     onPressed: () async {
//                       setState(() {
//                         loading = true;
//                       });
//                       if(_formKey.currentState!.validate()){
//                         if (widget.type == 'signin') {
//                           await AuthService().signInWithOTP(otpkey, widget.verID);
//                           Navigator.of(context).popUntil((route) => route.isFirst);
//                         } else {
//                           await AuthService().signUpWithOTP(otpkey, widget.verID, widget.uname, widget.phno, widget.email, widget.address, widget.lat, widget.long, widget.usrtype);
//                           Navigator.of(context).popUntil((route) => route.isFirst);
//                         }
//                       }
//                     }
//                   ),
                  
//                 ],
//               ),
//             ),
//           ],
//         ),
//       )
//     );
//   }
// }