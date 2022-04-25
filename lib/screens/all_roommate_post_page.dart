import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/roommate_post.dart';
import 'package:room_rental_app/utils/customised_app_bar.dart';
import 'package:room_rental_app/utils/loading.dart';
import 'package:room_rental_app/utils/nothing_found.dart';
import 'package:room_rental_app/utils/post_card.dart';

class AllRoommatePost extends StatefulWidget {
  const AllRoommatePost({Key? key}) : super(key: key);

  @override
  _AllRoommatePostState createState() => _AllRoommatePostState();
}

class _AllRoommatePostState extends State<AllRoommatePost> {
  @override
  Widget build(BuildContext context) {
    final List<RoommatePostData?>? allRoommatePostData = Provider.of<List<RoommatePostData?>?>(context);
    return SafeArea(child: Scaffold(
      body: allRoommatePostData == null ? Loading(false) : allRoommatePostData.isEmpty ? const NothingFound() :
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CustomisedAppBar(mainHeading: 'Roommate Posts', subHeading: 'Showing Recents First',isProfileSection: false,),
            Expanded(
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                shrinkWrap: true,
                itemCount: allRoommatePostData.length,
                  itemBuilder: (context,index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: PostCard(
                          roommatePostData: allRoommatePostData[index],
                          postData: null, isAllPost: true),
                    );
                  }
              ),
            ),
          ],
        ),
    ));
  }
}
