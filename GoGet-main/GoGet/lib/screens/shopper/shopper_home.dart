import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/getwidget.dart';
import 'package:gogetapp/screens/shopper/cart.dart';
import 'package:gogetapp/services/fire_auth.dart';
import 'package:gogetapp/widgets/spinner.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopperHome extends StatefulWidget {
  const ShopperHome({ Key? key }) : super(key: key);

  @override
  _ShopperHomeState createState() => _ShopperHomeState();
}

class _ShopperHomeState extends State<ShopperHome> {
  bool loading = false;

  var _searchText = '';
  var searchQuery = FirebaseFirestore.instance.collection('products').snapshots();

  final textfieldController = TextEditingController();

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState(){
    // displayAlert('Welcome $user!');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (_searchText == '' || _searchText.length <= 1) {
      // print (_searchText);
      searchQuery = FirebaseFirestore.instance.collection('products').snapshots();
    } else {
      // searchQuery = FirebaseFirestore.instance.collection('products').orderBy('prodName').startAt([_searchText]).endAt([_searchText + '\uf8ff']).snapshots();
      searchQuery = FirebaseFirestore.instance.collection('products').where('prodName', isGreaterThanOrEqualTo: _searchText).where('prodName', isLessThan: _searchText + '\uf8ff').snapshots();
      // print(searchQuery);
      }

    return loading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('GoGet'),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          
          IconButton(onPressed: (){ Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ShoppingCart())); }, icon: Icon(Icons.shopping_basket_outlined)),
          IconButton(onPressed: () async { AuthService().signOut(); }, icon: Icon(Icons.logout)),

        ],
        shadowColor: Colors.orange,
        ),

      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.orange,
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5.0),
              height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.055,
              
                child: TextField(
                  controller: textfieldController,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search, color: Colors.white,),
                    hintText: 'Search products here ...',
                    hintStyle: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(width: 1.0, color: Colors.white)
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 2.0, color: Colors.white)
                    )
                  ),
                  onChanged: (val) => {
                    setState(() {
                      _searchText = val;
                  })
                },
              ),
            ),
            SizedBox(height: 0.0,),
            Container(
              child: SingleChildScrollView(
                child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.87,
                  child: StreamBuilder(
                    stream: searchQuery,
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if( !snapshot.hasData ){ return new Text('Loading...'); }
                      else if( snapshot.data!.docs.length == 0) { return Center(child: Text('No products found'),); }
                      else return GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: (2 / 1.3),
                        padding: EdgeInsets.all(10.0),
                        children: snapshot.data!.docs.map(
                          (DocumentSnapshot document) {
                            
                            var imgAvbl = (document.data() as dynamic)['imgURL'] != '' ? 'YES' : 'NO';
                            return Container(
                              // decoration: new BoxDecoration(
                              //   boxShadow: [
                              //     new BoxShadow(
                              //       color: Colors.orange,
                              //       blurRadius: 5.0,
                              //     ),
                              //   ],
                              // ),
                              child: Card(
                                shadowColor: Colors.orange.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: 
                                  Column(
                                    children: [
                                      ListTile(
                                        leading: imgAvbl == 'YES' ? GFAvatar(radius: 40, size: GFSize.LARGE, shape: GFAvatarShape.standard, backgroundImage: NetworkImage((document.data() as dynamic)['imgURL']),) : GFAvatar(child: Icon(Icons.store, size: 50, color: Colors.black54)),
                                        title: Text('${(document.data() as dynamic)['prodName']}'),
                                        subtitle: Text('${(document.data() as dynamic)['price']}'),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                        
                                        TextButton.icon(onPressed: (){ _showaddcartdialog(document); }, icon: Icon(Icons.add_circle_outline), label: Text('Add to cart')),
                                      ],)
                                    ],
                                  ),
                                            
                                  
                                ),
                              );
                          }).toList(),
                      );
                    }
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  displayAlert(text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
      ));
  }

  _showaddcartdialog(document) async {
    var prodCount = 0;
    double qty = 0.0;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').get()
    .then((snapshot) async => {
      if (snapshot.docs.isNotEmpty){
        snapshot.docs.forEach((doc) {
          if (doc.id == document.id) {
            prodCount = prodCount + 1;
            qty = (doc.data() as dynamic)['qty'];
          }
        })
      }
    });
    // print(prodCount);
    // if (prodCount > 0) { displayAlert('Item already in your cart'); textfieldController.clear(); setState(() { _searchText = ''; }); FocusScope.of(context).unfocus(); }
    // else {
      double _qty = qty > 0 ? qty : 0.0; 
      double new_qty = 0.0;
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            elevation: 16,
            child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.28,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Center(child: Text((document.data() as dynamic)['prodName'], style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 20.0))),
                  SizedBox(height: 10),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 0),
                      Container(height: 2, color: Colors.redAccent),
                      SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[

                          Text('Quantity :', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),           
                          Container(width: 80.0, child: TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '$_qty'), onChanged: (val) => new_qty = double.parse(val),),),

                        ],
                      ),
                      SizedBox(height: 10,),
                      SizedBox(height: 10,),
                  ElevatedButton(child: Text('ADD'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange)),
                  onPressed: () async { 
                    if (new_qty != 0) { 
                    await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').doc(document.id).set({
                      'prodname' : (document.data() as dynamic)['prodName'],
                      'qty' : new_qty,
                    });
                    textfieldController.clear();
                    FocusScope.of(context).unfocus();
                    setState(() { _searchText = ''; });
                    Navigator.of(context).pop();
                    displayAlert('Item added to cart!');
                    } else {
                    displayAlert('Qty cannot be 0');}}
                  )
                ])
              )
            ])
          )
        );
        });
  }

}