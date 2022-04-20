import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:room_rental_app/models/post_data.dart';
import 'package:room_rental_app/models/roommate_post.dart';
import 'package:room_rental_app/screens/post_details_page.dart';
import 'package:room_rental_app/services/database_firestore.dart';
import 'package:room_rental_app/utils/device_size.dart';

import 'loading.dart';

class PostCard extends StatefulWidget {
  final PostData? postData;
  final RoommatePostData? roommatePostData;
  final bool isAllPost;
  final User? currentUser =
      FirebaseAuth.instance.currentUser; // I just marked it as final
  PostCard({Key? key, required this.postData, required this.isAllPost, required this.roommatePostData})
      : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('Users');
  bool isPhotoView = false;
  bool isRoommatePostLoading = false;
  bool isRoomPostLoading = false;
  @override
  Widget build(BuildContext context) {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;
    // print(widget.current_user!.uid);
    final _databaseService = DatabaseService(widget.currentUser!.uid);
    return widget.postData == null ?
    isRoommatePostLoading ? Loading(false) :
        //Roommate Post Data
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: Card(
        child: InkWell(
          onTap: openRoommatePostDetails,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: displayWidth(context) * 0.3,
                  width: displayWidth(context) * 0.3,
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.roommatePostData!.uplImgLink[0],
                      placeholder: (context, url) =>
                          smallLoadingIndicatorForImages(),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xfff5f5f5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 0),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.roommatePostData!.roomType,
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.08,
                          ),
                        ),
                        Text('Contact :' + widget.roommatePostData!.tenantContact,
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.05,
                          ),
                        ),
                        Row(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\u20B9' +
                                widget.roommatePostData!.orgPrice.toString() +
                                '/Month',
                              style: TextStyle(
                                fontSize: displayWidth(context) * 0.05,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            widget.isAllPost
                                ? const SizedBox(
                              height: 0,
                              width: 0,
                            )
                                : IconButton(
                              alignment: Alignment.center,
                              onPressed: () {
                                setState(()  {
                                  isRoommatePostLoading = true;
                                   userCollection.doc(currentUser!.uid).update(
                                      {
                                        'countRoommatePost' : 0,
                                      }
                                  );
                                  _databaseService.deleteRoommatePost(
                                      widget.roommatePostData!)!.whenComplete(() {
                                    isRoommatePostLoading=false;
                                  });
                                });
                              },
                              // padding: const EdgeInsets.all(0),
                              icon: Icon(Icons.delete,
                                  size: displayWidth(context)*0.05),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ) :
    isRoomPostLoading ? Loading(false) :
        //Room Post Data
    Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            child: Card(
              child: InkWell(
                onTap: openRoomPostDetails,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: displayWidth(context) * 0.3,
                        width: displayWidth(context) * 0.3,
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: widget.postData!.uplImgLink[0],
                            placeholder: (context, url) =>
                                smallLoadingIndicatorForImages(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xfff5f5f5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 0),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.postData!.roomType,
                                style: TextStyle(
                                  fontSize: displayWidth(context) * 0.08,
                                ),
                              ),
                              Text('Contact :' + widget.postData!.ownContact,
                                style: TextStyle(
                                  fontSize: displayWidth(context) * 0.05,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('\u20B9' +
                                      widget.postData!.price.toString() +
                                      '/Month',
                                    style: TextStyle(
                                      fontSize: displayWidth(context) * 0.05,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  widget.isAllPost
                                      ? const SizedBox(
                                    height: 0,
                                    width: 0,
                                  )
                                      : IconButton(
                                    alignment: Alignment.center,
                                          onPressed: () {
                                            setState(()  {
                                              isRoomPostLoading = true;
                                              _databaseService.deleteRoomPost(
                                                  widget.postData!)!.whenComplete(() {
                                                    isRoomPostLoading = false;
                                              });
                                            });
                                          },
                                    // padding: const EdgeInsets.all(0),
                                          icon: Icon(Icons.delete,
                                          size: displayWidth(context)*0.05),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  void openRoomPostDetails() => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PostDetails(
          roommatePostData: null,
          postData: widget.postData,
        ),
      ));
  void openRoommatePostDetails() => Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => PostDetails(
      roommatePostData: widget.roommatePostData,
      postData: null,
    ),
  ));
}

