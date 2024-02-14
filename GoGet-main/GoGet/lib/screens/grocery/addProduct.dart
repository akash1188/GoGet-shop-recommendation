import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/shape/gf_avatar_shape.dart';
import 'package:gogetapp/widgets/spinner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddProductSeller extends StatefulWidget {
  const AddProductSeller({ Key? key }) : super(key: key);

  @override
  _AddProductSellerState createState() => _AddProductSellerState();
}

class _AddProductSellerState extends State<AddProductSeller> {

  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  var _prodname = '';
  var _stock = 0.0;
  var _price = 0.0;
  bool loading = false;
  var avatarImgURL = '';
  
  @override
  Widget build(BuildContext context) {
    bool avatarImgavailable;
    if (avatarImgURL != '') {avatarImgavailable = true;} else {avatarImgavailable = false;}
    return loading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Add New Product'),
        centerTitle: true,
      ),
    body: Container(
        padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 60.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(key: _formKey,
              child: Column(
                children: [
                  
                  // SizedBox(height: 50.0,),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.label, color: Colors.orange,),
                      labelText: 'Product Name',
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
                    validator: (val) => val!.isEmpty ? 'Please provide product name' : null,
                    onChanged: (val) {
                      setState(() => _prodname = val);
                    }
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.more_horiz, color: Colors.orange,),
                      labelText: 'Count',
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
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Stock count is required' : null,
                    onChanged: (val) {
                      setState(() => _stock = double.parse(val));
                    }
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Text('\u{20B9}', textAlign: TextAlign.center, style: GoogleFonts.roboto(color: Colors.orange, fontSize: 32),),//Icon(Icons.store, color: Colors.orange,),
                      labelText: 'Unit Price',
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
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Price is mandatory' : null,
                    onChanged: (val) {
                      setState(() => _price = double.parse(val));
                    }
                  ),
                  SizedBox(height: 20.0),
                  
                  GestureDetector(
                    onTap: () async {
                      
                      final PickedFile? galImage = await ImagePicker().getImage(source: ImageSource.gallery);
                      final File image = File(galImage!.path);
                      displaySnackBar('Uploading Image. Hold on.');
                      firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref().child('products/${user!.uid}/');
                      
                      firebase_storage.TaskSnapshot storageTaskSnapshot = await storageRef.putFile(image);

                      var imgURL = await storageTaskSnapshot.ref.getDownloadURL();

                      setState((){ avatarImgURL = imgURL; });

                    },

                    child: avatarImgavailable
                      ? GFAvatar(
                          backgroundImage:NetworkImage(avatarImgURL),
                          shape: GFAvatarShape.standard
                        )
                        : GFAvatar(
                          child: Icon(Icons.store, size: 50, color: Colors.black54),
                          shape: GFAvatarShape.standard
                        ),
                    ),
                    SizedBox(height: 50.0),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange),),
                    child: Text('Add Product'),
                    onPressed: () async {
                      if (avatarImgURL != '') {
                      if(_formKey.currentState!.validate()){
                      setState(() {
                        loading = true;
                      });
                      var productid; 
                      await FirebaseFirestore.instance.collection('products').add({
                        'prodName' : _prodname,
                        'stockCount' : _stock,
                        'price' : _price,
                        'imgURL' : avatarImgURL,
                      }).then((docRef) => {productid = docRef.id});
                      await FirebaseFirestore.instance.collection('stores').doc(user!.uid).collection('products').doc(productid).set({
                        'prodName' : _prodname,
                        'stockCount' : _stock,
                        'price' : _price,
                        'imgURL' : avatarImgURL
                      });
                      Navigator.of(context).pop();
                    }} else {displaySnackBar('All fields are mandatory');}
                    }
                  ),
                ]),
            ),
          ]),
      ),
    );
  }
  displaySnackBar(errtext) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errtext),
        duration: const Duration(seconds: 5),
      ));
  }
}