import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogetapp/screens/grocery/newStore.dart';
import 'package:gogetapp/screens/grocery/search&add.dart';
import 'package:gogetapp/services/fire_auth.dart';
import 'package:gogetapp/widgets/spinner.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopHome extends StatefulWidget {
  const ShopHome({ Key? key }) : super(key: key);

  @override
  _ShopHomeState createState() => _ShopHomeState();
}

class _ShopHomeState extends State<ShopHome> {

  final User? user = FirebaseAuth.instance.currentUser;
  
  var storeName;
  var storePhno;
  var storeAdd;

  bool loading = false;

  late Future<DocumentSnapshot> groceryStore;

  @override
  void initState(){
    FirebaseFirestore.instance.collection('stores').doc(user!.uid).get().then((doc) async => {
        storeName = (doc.data() as dynamic) ['storeName'],
        storePhno = (doc.data() as dynamic)['phno'],
        storeAdd = (doc.data() as dynamic)['address'],
    });
    // displayAlert('Welcome $user!');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    getStoreName(){FirebaseFirestore.instance.collection('stores').doc(user!.uid).get().then((doc) async => {
      
          setState(() {
            
            storeName = (doc.data() as dynamic) ['storeName'];
            storePhno = (doc.data() as dynamic)['phno'];
            storeAdd = (doc.data() as dynamic)['address'];
          
          })
       });}
    

    getStoreName();

    return loading ? Loading() : Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: Text('$storeName'),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () async {storeEditDialog(storeName, storePhno, storeAdd); await getStoreName();}, icon: Icon(Icons.edit)),
            IconButton(onPressed: () async { AuthService().signOut(); }, icon: Icon(Icons.logout)),
          ],
        ),
        
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('stores').doc(user!.uid).collection('products').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

  // ***** CHECK IF STORE HAS PRODUCTS (--NO)
                if (snapshot.data != null){
                if (snapshot.data!.docs.length == 0) {
                  return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                      height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.05,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),)),
                          child: 
                            Center(
                              child: Text('No Products Found')),
                            ),
                  ]);
                }
  // ***** IF STORE HAS PRODUCTS 
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
                      height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.05,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),)),
                      child: Row(
                      children: [
                        Container(width: 200, child: Text('Product Name', overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),)),
                        Expanded(child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),)),
                        Expanded(child: Text('Unit Price (\u{20B9})',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),)
                      ],)
                    ),
                    Column(
                      children: [
                        SingleChildScrollView(
                          child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.72,
                            child: ListView(
                              children: snapshot.data!.docs.map(
                                (DocumentSnapshot document) {
                                  var imgAvble;
                                  if ((document.data() as dynamic)['imgURL'] != ''){imgAvble = 'YES';} else {imgAvble = 'NO';}
                                  return Container(
                                    height: 60,
                                    decoration: BoxDecoration( 
                                      border: Border(bottom: BorderSide(color: Colors.grey),),
                                    ),
                                    child: ListTile(
                                      leading: imgAvble == 'NO' ? CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.store),) : CircleAvatar(backgroundColor: Colors.grey, radius: 25.0, backgroundImage: NetworkImage((document.data() as dynamic)['imgURL']),),
                                      title: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Container(width: 130.0, child: Text((document.data() as dynamic)['prodName'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0),textAlign: TextAlign.start,)),
                                          Expanded(child: Text((document.data() as dynamic)['stockCount'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0),textAlign: TextAlign.center,)),
                                          Expanded(child: Text((document.data() as dynamic)['price'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0),textAlign: TextAlign.center,)),
                                        ],
                                      ),
                                      trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){ displayDeleteConfirm('Delete this product : ${(document.data() as dynamic)['prodName']} ?', document.id); },),
                                      onTap: (){
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
                                                    // _buildRow((document.data() as dynamic)['stockCount'], (document.data() as dynamic)['price']),
                                                    Padding(padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                                    child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: <Widget>[
                                                        SizedBox(height: 0),
                                                        Container(height: 2, color: Colors.redAccent),
                                                        SizedBox(height: 10),
                                                        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                          children: <Widget>[

                                                            Text('Quantity :', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),           
                                                            Container(width: 80.0, child: TextField(decoration: InputDecoration(labelText: '${(document.data() as dynamic)['stockCount']}'), onChanged: (val) => _qty = double.parse(val),)),

                                                          ],
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                          children: <Widget>[

                                                            Text('Price : (\u{20B9})', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                                            Container(width: 80.0, child: TextField(decoration: InputDecoration(labelText: '${(document.data() as dynamic)['price']}'), onChanged: (val) => _price = double.parse(val),)),
                                                            
                                                          ],
                                                        ),
                                                          
                                                    
                                                    SizedBox(height: 10,),
                                                    ElevatedButton(child: Text('Done'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange)),
                                                    onPressed: () async { 
                                                      if (_price > 0.0 || _qty > 0.0) {
                                                        setState(() { loading = true; });
                                                        await FirebaseFirestore.instance.collection('stores').doc(user!.uid).collection('products').doc(document.id).update({
                                                          'price' : _price > 0.0 ? _price : (document.data() as dynamic)['price'],
                                                          'stockCount' : _qty > 0.0 ? _qty : (document.data() as dynamic)['stockCount'],
                                                          // 'imgURL' : (document.data() as dynamic)['imgURL'],
                                                        });
                                                        setState(() { loading = false; });
                                                        Navigator.of(context).pop();

                                                      } else {displayAlert('No Changes to SAVE'); Navigator.of(context).pop();}
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
                                      },
                                    ),
                                  );
                                }
                              ).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else return Text('Loading ...');
            } 
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.orange,
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SearchNadd())); //AddProductSeller()));
          },
        ),
      );
    }
  

  // Future<DocumentSnapshot<Object?>> _getStoreDetails() async {
  //   var usrStore = await FirebaseFirestore.instance.collection('stores').doc(user!.uid).get();
  //   return usrStore;
  // }

  noStoreView() {
      return Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Text('NO STORES FOUND. PLEASE ADD A NEW STORE TO START ADDING PRODUCTS.',textAlign: TextAlign.center,)),
          SizedBox(height: 45.0,),
          ElevatedButton(onPressed: (){ Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AddNewStore())); }, child: Text('ADD STORE'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange)),)
        ],
      );
    } 
  
  displayAlert(text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
      ));
  }

  displayDeleteConfirm(text, id){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'YES',
          onPressed: () async {
            await FirebaseFirestore.instance.collection('stores').doc(user!.uid).collection('products').doc(id).delete();
          },
        ),
      ));
  }

  storeEditDialog(storeName, storePhno, storeAdd){

    var newStName, newStPhno, newStAdd;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 16,
          child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.47,
            child: Column(
              children: <Widget>[
                SizedBox(height: 30),
                Center(child: Text('Edit Store Details', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 20.0))),
                SizedBox(height: 10),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 0),
                      Container(height: 2, color: Colors.redAccent),
                      SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[

                          Container(
                            width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.6,
                            child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.store, color: Colors.orange,), labelText: '$storeName'), 
                            onChanged: (val) {
                              newStName = val;
                            })),

                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[

                          Container(
                            width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.6,
                            child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.location_on, color: Colors.orange,), labelText: '$storeAdd'), 
                            onChanged: (val) {
                              newStAdd = val;
                            })),

                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[

                          Container(

                            width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.6,
                            child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.phone, color: Colors.orange,), labelText: '$storePhno'), 
                            onChanged: (val) {
                              newStPhno = val;
                            })),
                            
                        ],
                      ),
                        
                  
                  SizedBox(height: 30,),
                  ElevatedButton(child: Text('Done'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange)),
                    onPressed: () async {
                      if (newStName != null || newStAdd != null || newStPhno != null){
                        await FirebaseFirestore.instance.collection('stores').doc(user!.uid).update({
                          'storeName' : newStName ?? storeName,
                          'phno' : newStPhno ?? storePhno,
                          'address' : newStAdd ?? storeAdd,
                        });
                        Navigator.of(context).pop();
                      } else {displayAlert('No Changes to SAVE'); Navigator.of(context).pop();}
                    } 
                  ),
                    ]),
          )])),
          );
      });

  }

}