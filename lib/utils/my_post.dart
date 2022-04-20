import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/our_user.dart';
import 'package:room_rental_app/models/post_data.dart';
import 'package:room_rental_app/models/roommate_post.dart';
import 'package:room_rental_app/utils/device_size.dart';
import 'package:room_rental_app/utils/loading.dart';
import 'package:room_rental_app/utils/post_card.dart';

import 'nothing_found.dart';

class MyPostList extends StatefulWidget {
  const MyPostList({Key? key}) : super(key: key);

  @override
  _MyPostListState createState() => _MyPostListState();
}

class _MyPostListState extends State<MyPostList> {
  @override
  Widget build(BuildContext context) {
    final List<RoommatePostData?>? userRoommatePostlist = Provider.of<List<RoommatePostData?>?>(context);
    final List<OurUser?>? userProfileData = Provider.of<List<OurUser?>?>(context);
    final List<PostData?>? userPostlist = Provider.of<List<PostData?>?>(context);
    if(userProfileData==null)
      {
        debugPrint('userProfile  is null');
        return Loading(false);
      }
    if(userPostlist==null)
      {
        return Loading(false);
      }
    if(userRoommatePostlist==null)
      { debugPrint('userRoommatePostlist is null');
        return Loading(false);}
    List<PostData> userNonNullPostList =
        List.from(userPostlist.where((val) => val != null));

    List<RoommatePostData> userNonNullRoommatePostList =
    List.from(userRoommatePostlist.where((val) => val != null));

    List<OurUser> userNonNullProfileData =
    List.from(userProfileData.where((val) => val != null));
    debugPrint(userNonNullProfileData.length.toString());
    return SafeArea(
      child: Scaffold(
        body: getOrientation(context) == Orientation.portrait ?  SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          scrollDirection: Axis.vertical,
          child: Column(
                  children: [
                     Icon(
                      Icons.person,
                      size: displayWidth(context)*0.5,
                       color: Colors.indigo,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ' + userNonNullProfileData[0].name.toString(),
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.065,
                          ),
                        ),
                        Text('From ' + userNonNullProfileData[0].belogsTo.toString()),
                        Text('Contact Mob : ' +
                            userNonNullProfileData[0].contactNumber.toString()),
                        Text('Contact Email ' + userNonNullProfileData[0].email.toString()),
                        Text('Profession : ' +
                            userNonNullProfileData[0].profession.toString()),
                      ],
                    ),
                    !userNonNullProfileData[0].isHomeOwner ? const SizedBox(height: 0, width: 0,) :  Text('Your Room for Rent Posts',
                    style: TextStyle(
                      fontSize: displayWidth(context)*0.05,
                    ),
                    ),
                    !userNonNullProfileData[0].isHomeOwner ? const SizedBox(height: 0, width: 0,) : userNonNullPostList.isEmpty
                        ? const Center(child:  NothingFound(),)
                        : ListView.builder(
                            shrinkWrap: true,
                            // scrollDirection: Axis.horizontal,
                            itemCount: userPostlist.length,
                            itemBuilder: (context, index) {
                              return PostCard(
                                roommatePostData: null,
                                  postData: userNonNullPostList[index], isAllPost: false);
                            },
                          ),

                    userNonNullProfileData[0].isHomeOwner ? const SizedBox(height: 0, width: 0,) : Text('Find Roommate Post',
                      style: TextStyle(
                        fontSize: displayWidth(context)*0.05,
                      ),
                    ),
                    userNonNullProfileData[0].isHomeOwner ? const SizedBox(height: 0, width: 0,) : userNonNullRoommatePostList.isEmpty
                        ? const Center(child:  NothingFound(),)
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: userNonNullRoommatePostList.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          postData: null,
                            roommatePostData: userNonNullRoommatePostList[index], isAllPost: false);
                      },
                    ),
                  ],
                ),
        )
       : const Text('Please hold your device in Portrait mode'),),
    );
  }
}
