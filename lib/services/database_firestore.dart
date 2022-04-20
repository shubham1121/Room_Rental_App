import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_rental_app/models/our_user.dart';
import 'package:room_rental_app/models/post_data.dart';
import 'package:room_rental_app/models/roommate_post.dart';

class DatabaseService {
  final String uid;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');
  final CollectionReference allPostCollection =
      FirebaseFirestore.instance.collection('All Post');
  final CollectionReference allRoommatePostCollection =
      FirebaseFirestore.instance.collection('All Roommate Post');
  DatabaseService(this.uid);

  Future updateUserData(
      String name,
      String contactNo,
      String profession,
      bool isHomeOwner,
      String email,
      int countRoommatePost,
      String belongsTo) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'contactNo': contactNo,
      'profession': profession,
      'isHomeOwner': isHomeOwner,
      'email': email,
      'countRoommatePost': countRoommatePost,
      'belongsTo': belongsTo,
      'userId': uid,
    });
  }

  List<OurUser?>? _ourUserListfromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return OurUser(
        name: doc.get('name') ?? "",
        contactNumber: doc.get('contactNo') ?? "",
        profession: doc.get('profession') ?? "",
        email: doc.get('email') ?? "",
        isHomeOwner: doc.get('isHomeOwner'),
        countRoommatePost: doc.get('countRoommatePost'),
        belogsTo: doc.get('belongsTo'),
        userId: doc.get('userId'),
      );
    }).toList();
  }
  //
  // Stream<List<OurUser>?>? get userData => userCollection
  //     .snapshots()
  //     .map((snapshot) => _ourUserListfromSnapshot(snapshot));

  // List<OurUser?> _ourUserProfilefromSnapshot(QuerySnapshot snapshot) {
  //   return snapshot.docs.map((doc) {
  //     debugPrint(doc.get('userId')+'Our User');
  //     return OurUser(
  //       name: doc.get('name') ?? "",
  //       contactNumber: doc.get('contactNo') ?? "",
  //       profession: doc.get('profession') ?? "",
  //       email: doc.get('email') ?? "",
  //       isHomeOwner: doc.get('isHomeOwner'),
  //       wantRoommate: doc.get('wantRoommate'),
  //       countRoommatePost: doc.get('countRoommatePost'),
  //       belogsTo: doc.get('belongsTo'),
  //       userId: doc.get('userId'),
  //     );
  //   }).toList();
  // }

  Stream<List<OurUser?>?> get ourUserProfileData {
    return userCollection
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => _ourUserListfromSnapshot(snapshot));
  }

  Future<String?> uploadImageFirebaseStorage(File img) async {
    late UploadTask uploadTask;
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('images/${path.basename(img.path)}');
      uploadTask = storageReference.putFile(img);
    } on FirebaseException catch (e) {
      debugPrint(e.message);
      return null;
    }
    final snapshot = await uploadTask.whenComplete(() => {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    return urlDownload;
  }

  Future? addRoomPost(PostData post) async {
    String uploadResult = await allPostCollection.add({
      'roomType': post.roomType,
      'address': post.ownAddress,
      'upldate': post.date,
      'userId': uid,
      'postId': "",
      'city': post.city,
      'state': post.state,
      'pinCode': post.pinCode,
      'ownerName': post.ownName,
      'ownerContact': post.ownContact,
      'furnished': post.isFurnished,
      'visible': post.isVisible,
      'beds': post.beds,
      'price': post.price,
      'images': FieldValue.arrayUnion(post.uplImgLink),
    }).then((value) async {
      await allPostCollection.doc(value.id).update({
        'postId': value.id.toString(),
      });
      return "Success";
    }).catchError((error) => "Error Found");
    if (uploadResult == "Error Found") {
      return "Error";
    }
  }

  Future? addRoommatePost(RoommatePostData post) async {
    String uploadResult = await allRoommatePostCollection.add({
      'roomType': post.roomType,
      'address': post.ownAddress,
      'upldate': post.date,
      'userId': uid,
      'postId': "",
      'city': post.city,
      'state': post.state,
      'pinCode': post.pinCode,
      'ownerName': post.ownName,
      'tenantContact': post.tenantContact,
      'furnished': post.isFurnished,
      'visible': post.isVisible,
      'beds': post.beds,
      'perPersonPrice': post.perPersonPrice,
      'price': post.orgPrice,
      'myName': post.myName,
      'images': FieldValue.arrayUnion(post.uplImgLink),
    }).then((value) async {
      await allRoommatePostCollection.doc(value.id).update({
        'postId': value.id.toString(),
      });
      return "Success";
    }).catchError((error) => "Error Found");
    if (uploadResult == "Error Found") {
      return "Error";
    }
  }

  // All Post Data
  List<PostData?>? _ourPostListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      PostData postData = PostData(
        city: doc.get('city'),
        state: doc.get('state'),
        pinCode: doc.get('pinCode'),
        roomType: doc.get('roomType'),
        ownAddress: doc.get('address'),
        userId: doc.get('userId'),
        isFurnished: doc.get('furnished'),
        isVisible: doc.get('visible'),
        beds: doc.get('beds'),
        price: doc.get('price'),
        date: doc.get('upldate'),
        ownContact: doc.get('ownerContact'),
        ownName: doc.get('ownerName'),
      );
      postData.uplImgLink = doc.get('images');
      postData.postId = doc.get('postId');
      return postData;
    }).toList();
  }

  Stream<List<PostData?>?> get allPostData => allPostCollection
      .orderBy("upldate")
      .snapshots()
      .map((snapshot) => _ourPostListFromSnapshot(snapshot));

  Stream<List<PostData?>?> get userPostData => allPostCollection
      .where('userId', isEqualTo: uid)
      .orderBy('upldate')
      .snapshots()
      .map((snapshot) => _ourPostListFromSnapshot(snapshot));

  //Roommate Post Data
  List<RoommatePostData?>? _ourRoommatePostListFromSnapshot(
      QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      debugPrint(uid);
      debugPrint(doc.get('userId'));
      RoommatePostData postData = RoommatePostData(
        perPersonPrice: doc.get('perPersonPrice'),
        myName: doc.get('myName'),
        city: doc.get('city'),
        state: doc.get('state'),
        pinCode: doc.get('pinCode'),
        roomType: doc.get('roomType'),
        ownAddress: doc.get('address'),
        userId: doc.get('userId'),
        isFurnished: doc.get('furnished'),
        isVisible: doc.get('visible'),
        beds: doc.get('beds'),
        orgPrice: doc.get('price'),
        date: doc.get('upldate'),
        tenantContact: doc.get('tenantContact'),
        ownName: doc.get('ownerName'),
      );
      postData.uplImgLink = doc.get('images');
      postData.postId = doc.get('postId');
      return postData;
    }).toList();
  }

  Stream<List<RoommatePostData?>?> get allRoommatePostData =>
      allRoommatePostCollection
          .orderBy('upldate')
          .snapshots()
          .map((snapshot) => _ourRoommatePostListFromSnapshot(snapshot));

  Stream<List<RoommatePostData?>?> get userRoommatePostData =>
      allRoommatePostCollection
          .where('userId', isEqualTo: uid)
          .snapshots()
          .map((snapshot) => _ourRoommatePostListFromSnapshot(snapshot));

  //Delete Post
  Future? deleteRoomPost(PostData postData) async {
    for (var pD in postData.uplImgLink) {
      await FirebaseStorage.instance.refFromURL(pD).delete();
    }
    await allPostCollection
        .doc(postData.postId)
        .delete()
        .then((value) => "Deleted")
        .catchError((error) => "Error");
    return null;
  }

  Future? deleteRoommatePost(RoommatePostData postData) async {
    for (var pD in postData.uplImgLink) {
      await FirebaseStorage.instance.refFromURL(pD).delete();
    }
    await allRoommatePostCollection
        .doc(postData.postId)
        .delete()
        .then((value) => "Deleted")
        .catchError((error) => "Error");
    return null;
  }
}
