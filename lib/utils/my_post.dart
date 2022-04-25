import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/our_user.dart';
import 'package:room_rental_app/models/post_data.dart';
import 'package:room_rental_app/models/roommate_post.dart';
import 'package:room_rental_app/services/firebase_auth.dart';
import 'package:room_rental_app/utils/constants.dart';
import 'package:room_rental_app/utils/customised_app_bar.dart';
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
    final AuthService _authService = AuthService();
    final List<RoommatePostData?>? userRoommatePostlist =
        Provider.of<List<RoommatePostData?>?>(context);
    final List<OurUser?>? userProfileData =
        Provider.of<List<OurUser?>?>(context);
    final List<PostData?>? userPostlist =
        Provider.of<List<PostData?>?>(context);
    if (userProfileData == null) {
      debugPrint('userProfile  is null');
      return Loading(false);
    }
    if (userPostlist == null) {
      return Loading(false);
    }
    if (userRoommatePostlist == null) {
      debugPrint('userRoommatePostlist is null');
      return Loading(false);
    }
    List<PostData> userNonNullPostList =
        List.from(userPostlist.where((val) => val != null));

    List<RoommatePostData> userNonNullRoommatePostList =
        List.from(userRoommatePostlist.where((val) => val != null));

    List<OurUser> userNonNullProfileData =
        List.from(userProfileData.where((val) => val != null));
    debugPrint(userNonNullProfileData.length.toString());
    return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: displayWidth(context),
              decoration: const BoxDecoration(
                color: darkBlueColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const CustomisedAppBar(
                      mainHeading: 'Profile',
                      subHeading: 'Checkout Your Details and Posts!',
                      isProfileSection: true,
                    ),
                    Icon(
                      Icons.person,
                      size: displayWidth(context) * 0.35,
                      color: Colors.indigo,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userNonNullProfileData[0].name.toString(),
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.09,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          userNonNullProfileData[0].email.toString(),
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.04,
                            color: darkGreyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          userNonNullProfileData[0].contactNumber.toString() +
                              '|' +
                              userNonNullProfileData[0].belogsTo.toString(),
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.04,
                            color: darkGreyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 10),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _authService.logout();
                          });
                        },
                        label: const Text('Logout'),
                        icon: const Icon(Icons.logout),
                        style:
                            ElevatedButton.styleFrom(primary: lightBlueColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              child: Column(
                children: [
                  Text(
                    'Your Posts',
                    style: TextStyle(
                      fontSize: displayWidth(context) * 0.08,
                      fontWeight: FontWeight.w600,
                      color: darkBlueColor,
                    ),
                  ),
                  !userNonNullProfileData[0].isHomeOwner
                      ? const SizedBox(
                          height: 0,
                          width: 0,
                        )
                      : userNonNullPostList.isEmpty
                          ? const Center(
                              child: NothingFound(),
                            )
                          : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                            // scrollDirection: Axis.vertical,
                              itemCount: userPostlist.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                  child: PostCard(
                                      roommatePostData: null,
                                      postData: userNonNullPostList[index],
                                      isAllPost: false),
                                );
                              },
                            ),
                  userNonNullProfileData[0].isHomeOwner
                      ? const SizedBox(
                          height: 0,
                          width: 0,
                        )
                      : userNonNullRoommatePostList.isEmpty
                          ? const Center(
                              child: NothingFound(),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: userNonNullRoommatePostList.length,
                              itemBuilder: (context, index) {
                                return PostCard(
                                    postData: null,
                                    roommatePostData:
                                        userNonNullRoommatePostList[index],
                                    isAllPost: false);
                              },
                            ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
