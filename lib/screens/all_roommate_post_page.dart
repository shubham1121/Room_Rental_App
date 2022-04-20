import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/roommate_post.dart';
import 'package:room_rental_app/services/firebase_auth.dart';
import 'package:room_rental_app/utils/loading.dart';
import 'package:room_rental_app/utils/nothing_found.dart';
import 'package:room_rental_app/utils/post_card.dart';

class AllRoommatePost extends StatefulWidget {
  const AllRoommatePost({Key? key}) : super(key: key);

  @override
  _AllRoommatePostState createState() => _AllRoommatePostState();
}

class _AllRoommatePostState extends State<AllRoommatePost> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final List<RoommatePostData?>? allRoommatePostData = Provider.of<List<RoommatePostData?>?>(context);
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Roommate Post'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _authService.logout();
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: allRoommatePostData == null ? Loading(false) : allRoommatePostData.isEmpty ? const NothingFound() :
        ListView.builder(
          itemCount: allRoommatePostData.length,
            itemBuilder: (context,index) {
              return PostCard(
                  roommatePostData: allRoommatePostData[index],
                  postData: null, isAllPost: true);
            }
        ),
    ));
  }
}
