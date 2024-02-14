import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// final User? user = FirebaseAuth.instance.currentUser;

storeSuggestions(context, currUser) async {
  
  // var usrID = user!.uid;
  var usrLat;
  var usrLong;
  List cartItemsList = [];
  List totPriceList = []; // to find the median
  double itemcost;
  var median;

//**** DELETE PREVIOUS SUGGESTIONS */
  await FirebaseFirestore.instance.collection('users').doc(currUser).collection('suggestions').get().then((allDocsSnap) async => {
    for (DocumentSnapshot suggDocs in allDocsSnap.docs){
      suggDocs.reference.delete(),
    }
  });


//**** FETCH USER LOCATION */
  await FirebaseFirestore.instance.collection('users').doc(currUser).get().then((userDoc) => {
    if (userDoc.exists) {
      usrLat = double.parse((userDoc.data() as dynamic)['lat']),
      usrLong = double.parse((userDoc.data() as dynamic)['long'])
    }
  });

//**** FETCH ALL PRODUCTS FROM USER CART */
  await FirebaseFirestore.instance.collection('users').doc(currUser).collection('cart').get().then((cartSnapShot) async => {
    if (cartSnapShot.docs.length > 0){
      // print('cart length = ${cartSnapShot.docs.length}'),
      for (DocumentSnapshot cartProduct in cartSnapShot.docs){
        cartItemsList.add(
          cartItems(
            itemid: cartProduct.id, 
            qty: (cartProduct.data() as dynamic) ['qty'],
          )
        )
      }
    }
  });

  var storeID;
  var storeName;
  var storeAdd;
  var storePhNo;
  var storeLat;
  var storeLong;
  var distanceInMtrs;
  List storeProdList = [];
  var unavailable = [];
  int unavailableCount= 0;
  int itemsMatched = 0;
  double totalCost;
  double storeRating;
  double totPrice;
  int stCount;
  double X;
  double score;
  // var cCount = 0;
  // var sCount = 0;

//**** FETCH ALL STORES FROM STORE TABLE */  
  await FirebaseFirestore.instance.collection('stores').get().then((storeSnapshot) async => {
    if (storeSnapshot.docs.length > 0) {
      for (DocumentSnapshot storeDoc in storeSnapshot.docs) {
        itemsMatched = 0,
        totalCost = 0.0,
        // cCount = 0,
        // sCount = 0,
        storeProdList.clear(),
        unavailable.clear(),
        unavailableCount = 0,
        storeID = storeDoc.id,
        storeName = (storeDoc.data() as dynamic)['storeName'],
        storeRating = (storeDoc.data() as dynamic)['rating'],
        // print('storeID: ${storeDoc.id}'),
        await FirebaseFirestore.instance.collection('users').doc(storeID).get().then((storeDoc) async => {
          if (storeDoc.exists) {
            storeLat = double.parse((storeDoc.data() as dynamic)['lat']),
            storeLong = double.parse((storeDoc.data() as dynamic)['long']),
            storeAdd = (storeDoc.data() as dynamic)['address'],
            storePhNo = (storeDoc.data() as dynamic)['phno'],
          }          
        }),
//**** DISTANCE OF STORE FROM USER */
        distanceInMtrs = double.parse((Geolocator.distanceBetween(usrLat, usrLong, storeLat, storeLong)/1000).toStringAsFixed(2)),
  //**** FETCH ALL PRODUCTS FROM STORE */
          await FirebaseFirestore.instance.collection('stores').doc(storeID).collection('products').get().then((storeProdSnapShot) async => {
            if (storeProdSnapShot.docs.length > 0){
              for (DocumentSnapshot storeProduct in storeProdSnapShot.docs){
                storeProdList.add(
                  storeProd(
                    itemid: storeProduct.id, 
                    cost: (storeProduct.data() as dynamic) ['price'],
                    prodName: (storeProduct.data() as dynamic) ['prodName']
                  )
                )                   
              }
            }
          }),
            for(storeProd sItem in storeProdList){
            for(cartItems cItem in cartItemsList){
              
                itemcost = 0,
              if (cItem.itemid == sItem.itemid) {
                print ('Cart: ${cItem.itemid}'),
                print ('Shop: ${sItem.itemid}'),
                print ('Shop: ${sItem.prodName}'),
                itemsMatched = itemsMatched+1,
                itemcost = (cItem.qty) * (sItem.cost),
                totalCost = totalCost + itemcost,
                await FirebaseFirestore.instance.collection('users').doc(currUser).collection('suggestions').doc(storeID).collection('prods').doc(cItem.itemid).set({
                  'prodName' : sItem.prodName, 
                  'qty' : cItem.qty , 
                  'unitPrice' : sItem.cost,
                  'cost' : itemcost
                }),
              } else {unavailableCount = unavailableCount + 1, print(unavailableCount)}
            },
          },
          await FirebaseFirestore.instance.collection('users').doc(currUser).collection('suggestions').doc(storeID).set({
            'storeName': storeName,
            'storeAdd' : storeAdd,
            'storePhNo' : storePhNo,
            'rating' : storeRating,
            'distance' : distanceInMtrs,
            'totalCost' : totalCost,
            'availability' : itemsMatched,
          }),
          totPriceList.add(totalCost),
          // print(totPriceList),
        }
      }
  });

// MEDIAN CALCULATION {(N+1)/2}th
  //** FIND THE NUMBER OF STORES */
  totPriceList.sort();
  stCount = totPriceList.length;
  //*** IF EVEN */
  if (stCount.isOdd && stCount > 2){
    // print ('count is ODD');
    median = totPriceList[((stCount)~/2)+1];
    // print(median);
  }
  else if (stCount.isEven){
    // print ('count is EVEN');
    median = ((totPriceList[(stCount~/2)-1]) + (totPriceList[(stCount~/2)]))/2;
    // print(median);
  } 

// CALCULATE FOR X FOR EACH STORE IN SUGGESTIONS
  await FirebaseFirestore.instance.collection('users').doc(currUser).collection('suggestions').get().then((suggestionsDoc) async => {
    for(DocumentSnapshot sDoc in suggestionsDoc.docs) {
      totPrice = (sDoc.data() as dynamic)['totalCost'],
      storeRating = (sDoc.data() as dynamic)['rating'],
      if (totPrice <= median){
        X = median - totPriceList[1],
      } else { X = (median - totPriceList[stCount-1]) * (-1)},

// CALCULATE FOR FINAL SCORE
      score = (storeRating * 20) + X,
      await sDoc.reference.update({ 'median' : median, 'X' : X, 'score' : score,})
    }
  });

return (Text('Done'));  

}

class cartItems {

  String itemid;
  double qty;

  cartItems({ required this.itemid, required this.qty });

}

class storeProd {

  String itemid, prodName;
  double cost;

  storeProd({ required this.itemid, required this.prodName, required this.cost });

}