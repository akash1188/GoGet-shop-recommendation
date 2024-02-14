import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommScreen extends StatefulWidget {
  const RecommScreen({ Key? key }) : super(key: key);

  @override
  _RecommScreenState createState() => _RecommScreenState();
}

class _RecommScreenState extends State<RecommScreen> {

  User? user = FirebaseAuth.instance.currentUser;
  var query;

  @override
  void initState() {
    query = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('suggestions').
    where('availability', isGreaterThan: 0).orderBy('availability', descending : true).
    // where('distance', isLessThanOrEqualTo: 30).orderBy('distance', descending: true).
    orderBy('score', descending : true).snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // var query = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('suggestions').where('availability', isGreaterThan: 0).orderBy('availability', descending : true).orderBy('score', descending : true).snapshots();
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Store Recommendations'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){_showSortDialog();}, icon: Icon(Icons.sort_sharp))
        ],
      ),

      body: SingleChildScrollView(
        child: Container(
          height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                height: 0.04 * (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom)),
                padding: const EdgeInsets.fromLTRB(40.0, 0, 0.0, 0),
                  child:Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Store')),
                      Expanded(child: Text('Distance')),
                      Expanded(child: Text('Bill')),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.86,
                      child: StreamBuilder(
                      stream: query, //FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('suggestions').where('availability', isGreaterThan: 0).orderBy('availability', descending : true).orderBy('score', descending : true).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if( !snapshot.hasData ){ return new Text('Loading...'); }
                          else return ListView(
                            children: snapshot.data!.docs.map(
                              (DocumentSnapshot document) {
                                
                                var stRating = (document.data() as dynamic)['rating'];
                                var stAvailability = (document.data() as dynamic)['availability'];
                                var distance = (document.data() as dynamic)['distance'];
                                var visibility = true;
                                if (distance > 30){ visibility = false; } else { visibility = true; } 
                                
                                return Visibility(visible: visibility,
                                  child: Container(
                                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),),),
                                    child: ExpansionTile(
                                      textColor: Colors.black,
                                      collapsedTextColor: Colors.black,
                                      title: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text((document.data() as dynamic)['storeName'], style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0))),
                                          Expanded(child: Text('${(document.data() as dynamic)['distance']} kms', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontSize: 12.0))),
                                          Expanded(child: Text('\u20B9 ${(document.data() as dynamic)['totalCost']}', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontSize: 12.0))),
                                        ],
                                      ),
                                      subtitle: Text('Items available: $stAvailability'),
                                      children: [
                                        Container(
                                          width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right)),
                                          child: Column(
                                            children: [
                                              Row(mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  
                                                  Container(padding: EdgeInsets.only(left: 10.0),
                                                    width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right)) * 0.74,
                                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('Address :', style: GoogleFonts.openSans(fontWeight: FontWeight.bold),),
                                                        SizedBox(height: 5,),
                                                        Text((document.data() as dynamic)['storeAdd'],),
                                                        SizedBox(height: 5,),
                                                        Row(
                                                          children: [
                                                            Icon(Icons.phone, size: 18.0,),
                                                            SizedBox(width: 10.0,),
                                                            Text((document.data() as dynamic)['storePhNo'],),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right)) * 0.24,
                                                    child:_showRating(stRating, document),
                                                  )
                                                ],
                                              ),
                                              Divider(color: Colors.grey,),
                                              SingleChildScrollView(
                                                child: Container(
                                                  padding: const EdgeInsets.only(top: 5.0),
                                                  height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.39,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                      height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom)) * 0.04,
                                                      width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right)),
                                                      // padding: const EdgeInsets.only(top: 25.0),
                                                        child:Row(//mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                          children: [
                                                            Container(
                                                              width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.49,
                                                              padding: EdgeInsets.only(right: 80),
                                                              child: Text('Item'), alignment: Alignment.center,),
                                                            Container(
                                                              width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.2,
                                                              child: Text('Unit Price'), alignment: Alignment.centerLeft,),
                                                            Container(
                                                              width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.2,
                                                              padding: EdgeInsets.only(right: 50),
                                                              child: Text('Qty'), alignment: Alignment.center,),
                                                            Container(
                                                              width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.11,
                                                              child: Text('Cost'), alignment: Alignment.centerLeft,)
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right)),
                                                        height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.3,
                                                        child: StreamBuilder(
                                                          stream: document.reference.collection('prods').snapshots(),
                                                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> prodsnapshot) {
                                                            if( !prodsnapshot.hasData ){ return new Text('Loading...'); }
                                                            else return ListView(
                                                              children: prodsnapshot.data!.docs.map(
                                                                (DocumentSnapshot proddocument) {
                                                                  return ListTile(
                                                                    title: Row(
                                                                      children: [
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.4,
                                                                          child: Text((proddocument.data() as dynamic)['prodName'], style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0)), alignment: Alignment.centerLeft),
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.2,                                                                        child: Text('${(proddocument.data() as dynamic)['unitPrice']}', style: GoogleFonts.openSans(fontSize: 14.0)), alignment: Alignment.center),
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.2,
                                                                          child: Text('${(proddocument.data() as dynamic)['qty']}', style: GoogleFonts.openSans(fontSize: 14.0)), alignment: Alignment.center),
                                                                        // Container(
                                                                        //   width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.2,
                                                                        //   child: Text('${(proddocument.data() as dynamic)['cost']}', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0)), alignment: Alignment.center),
                                                                      ],
                                                                    ),
                                                                    trailing: Text('${(proddocument.data() as dynamic)['cost']}', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                                                  );
                                                                }).toList(),
                                                            );
                                                          }
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),  
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            ).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ),
      ),
    );        
  }
  _showRating(double rating, doc){
    return RatingBar.builder(
      initialRating: rating,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 18.0,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (newrating) async {
        setState(() {
          rating = (rating + newrating)/2;
        });
        await FirebaseFirestore.instance.collection('stores').doc(doc.id).update({
          'rating': rating,
        });
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('suggestions').doc(doc.id).update({
          'rating': rating,
        });
      },
    );
  }

  _showSortDialog(){
      showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 16,
          child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.28,
            child: Column(
              children: <Widget>[
                SizedBox(height: 30),
                Center(child: Text('Sort By', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 20.0))),
                SizedBox(height: 10),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 0),
                      Container(height: 2, color: Colors.redAccent),
                      SizedBox(height: 20),
                      TextButton(child: Text('GoGet Recommendations', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16.0)), onPressed: (){
                        setState(() { query = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('suggestions').where('availability', isGreaterThan: 0).orderBy('availability', descending : true).orderBy('score', descending : true).snapshots(); });
                        Navigator.of(context).pop();
                      },),
                      SizedBox(height: 5,),
                      TextButton(child: Text('Distance', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16.0)), onPressed: (){
                        setState(() { query = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('suggestions').where('availability', isGreaterThan: 0).orderBy('availability', descending : true).orderBy('distance', descending : false).snapshots(); });
                        Navigator.of(context).pop();
                      },),
          ])),]))
          );
      });

  }
}