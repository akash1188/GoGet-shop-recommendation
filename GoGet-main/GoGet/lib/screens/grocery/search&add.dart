import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogetapp/screens/grocery/addProduct.dart';
import 'package:gogetapp/widgets/spinner.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchNadd extends StatefulWidget {
  const SearchNadd({ Key? key }) : super(key: key);

  @override
  _SearchNaddState createState() => _SearchNaddState();
}

/// ********** SELLERS CAN SEARCH AND ADD PRODUCTS TO THEIR STORES

class _SearchNaddState extends State<SearchNadd> {

  bool loading = false;

  var _searchText = '';
  var searchQuery = FirebaseFirestore.instance.collection('products').snapshots();

  final textfieldController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

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
      // appBar: AppBar(
      //   backgroundColor: Colors.orange,
      //   title: Text('Product Search'),
      //   shadowColor: Colors.orange,
      //   ),

      body: Container(
        // height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*1.5,
        child: Column(
          children: [
            Container(
              color: Colors.orange,
              padding: EdgeInsets.fromLTRB(00.0, 30.0, 00.0, 10.0),
              height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.11,
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back, color: Colors.white,), onPressed: (){ Navigator.of(context).pop(); },),
                  Container( 
                    padding: EdgeInsets.only(left: 20.0),
                    width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.85,
                    child: TextField(
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
                ],
              ),
            ),
            SizedBox(height: 0.0,),
            Container(
              child: SingleChildScrollView(
                child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.91,
                  child: StreamBuilder(
                    stream: searchQuery,
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if( !snapshot.hasData ){ return new Text('Loading...'); }
                      else if( snapshot.data!.docs.length == 0) { return new TextButton(child: Text('No products found. Click here to manually?'), onPressed: () {
                        textfieldController.clear();
                        FocusScope.of(context).unfocus();
                        setState(() { _searchText = ''; });
                        
                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AddProductSeller(),));
                        
                      });}
                      else return ListView(
                        children: snapshot.data!.docs.map(
                          (DocumentSnapshot document) {
                            var imgAvble;
                            if ((document.data() as dynamic)['imgURL'] != ''){imgAvble = 'YES';} else {imgAvble = 'NO';}

                            return Container(
                              // height: 49,
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),),),
                              child: ListTile(
                                leading: imgAvble == 'NO' ? CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.store),) : CircleAvatar(backgroundColor: Colors.grey, radius: 25.0, backgroundImage: NetworkImage((document.data() as dynamic)['imgURL']),),
                                title: Text((document.data() as dynamic)['prodName'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0),textAlign: TextAlign.left,),
                                trailing: OutlinedButton.icon(icon: Icon(Icons.add_circle_outline), label: Text('Add to Store'), onPressed: () async {
                                  // *** CHECK IF PRODUCT ALREADY ADDED TO STORE
                                  var prodCount = 0;
                                  await FirebaseFirestore.instance.collection('stores').doc(user!.uid).collection('products').get()
                                  .then((snapshot) async => {
                                    if (snapshot.docs.isNotEmpty){
                                      snapshot.docs.forEach((doc) {
                                        if (doc.id == document.id) {
                                          prodCount = prodCount + 1;
                                          // print(prodCount);
                                        }
                                      })
                                    }
                                  });
                                  // print(prodCount);
                                  if (prodCount > 0) { displayAlert('Item already available in your store'); textfieldController.clear(); setState(() { _searchText = ''; }); FocusScope.of(context).unfocus(); }

                                  else {

                                    double _qty = 0.0; 
                                    double _price = 0.0;
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                          elevation: 16,
                                          child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.35,
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
                                                        Container(width: 80.0, child: TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '0.0'), onChanged: (val) => _qty = double.parse(val),)),

                                                      ],
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: <Widget>[

                                                        Text('Price : (\u{20B9})', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                                        Container(width: 80.0, child: TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '0.0'), onChanged: (val) => _price = double.parse(val),)),
                                                        
                                                      ],
                                                    ),
                                                      
                                                  
                                                SizedBox(height: 10,),
                                                ElevatedButton(child: Text('Done'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange)),
                                                onPressed: () async { 
                                                  if (_qty > 0.0) {
                                                    setState(() { loading = true; });
                                                    await FirebaseFirestore.instance.collection('stores').doc(user!.uid).collection('products').doc(document.id).set({
                                                      'prodName' : (document.data() as dynamic)['prodName'],
                                                      'price' : _price,
                                                      'stockCount' : _qty,
                                                      'imgURL' : (document.data() as dynamic)['imgURL'],
                                                    });
                                                    setState(() { loading = false; });
                                                    Navigator.of(context).pop();

                                                    textfieldController.clear();
                                                    FocusScope.of(context).unfocus();
                                                    setState(() { _searchText = ''; });

                                                  } else {
                                                    displayAlert('Not added to store as Quantity = 0'); 
                                                    Navigator.of(context).pop();
                                                  }
                                                }, 
                                                )
                                                ],
                                                ),
                                            )],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                }),                                
                              )
                            );
                          }
                        ).toList(),
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
}