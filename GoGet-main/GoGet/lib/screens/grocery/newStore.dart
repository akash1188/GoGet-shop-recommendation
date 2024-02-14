import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNewStore extends StatefulWidget {
  const AddNewStore({ Key? key }) : super(key: key);

  @override
  _AddNewStoreState createState() => _AddNewStoreState();
}

class _AddNewStoreState extends State<AddNewStore> {

  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  var _storename = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Store Front'),
        centerTitle: true,
        // actions: [
        //   TextButton(onPressed: () async { 
        //     await FirebaseFirestore.instance.collection('stores').doc(user!.uid).set({
        //       'storename' : _storename;
        //       'createdDt' : DateTime.now();
        //     });
        //    }, child: Text('SAVE')),
        // ]
      ),

      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(key: _formKey,
              child: Column(
                children: [
                  
                  SizedBox(height: 50.0,),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.store, color: Colors.orange,),
                      labelText: 'Store Name',
                      labelStyle: GoogleFonts.openSans(color: Colors.black54),
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
                    validator: (val) => val!.isEmpty ? 'Please provide your store name' : null,
                    onChanged: (val) {
                      setState(() => _storename = val);
                    }
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange),),
                    child: Text('Confirm'),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      await FirebaseFirestore.instance.collection('stores').doc(user!.uid).set({
                        'storename' : _storename,
                        'createdDt' : DateTime.now(),
                        'rating' : 0.0,
                      });
                      Navigator.of(context).pop();
                    }
                  ),
                ]),
            ),
          ]),
      ),
    );
  }
}