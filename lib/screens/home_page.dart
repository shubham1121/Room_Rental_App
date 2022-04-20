import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/our_user.dart';
import 'package:room_rental_app/models/post_data.dart';
import 'package:room_rental_app/models/roommate_post.dart';
import 'package:room_rental_app/screens/all_roommate_post_page.dart';
import 'package:room_rental_app/services/database_firestore.dart';
import 'package:room_rental_app/services/firebase_auth.dart';
import 'package:room_rental_app/utils/loading.dart';
import 'package:room_rental_app/screens/my_profile_page.dart';
import 'package:room_rental_app/screens/all_room_post_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'create_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pagesOwner = [
    const AllRoomPost(),
    CreatePostPage(),
    const MyProfilePage(),
  ];
  final List<Widget> _pagesTenant = [
    const AllRoomPost(),
    CreatePostPage(),
    const AllRoommatePost(),
    const MyProfilePage(),
  ];
  int currentIndex = 0;
  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final List<OurUser?>? ourUserProfile = Provider.of<List<OurUser?>?>(context);
    return SafeArea(
      child: user == null || ourUserProfile == null
          ? Loading(false)
          : MultiProvider(
              providers: [
                StreamProvider<List<PostData?>?>.value(
                  value: DatabaseService(user.uid).allPostData,
                  initialData: null,
                ),
                StreamProvider<List<RoommatePostData?>?>.value(
                  catchError: (_, __) => null,
                  value: DatabaseService(user.uid).allRoommatePostData,
                  initialData: null,
                ),
              ],
              child: Scaffold(
                body: ourUserProfile[0]!.isHomeOwner ? _pagesOwner[currentIndex] : _pagesTenant[currentIndex],
                bottomNavigationBar: SalomonBottomBar(
                  currentIndex: currentIndex,
                  onTap: onTabTapped,
                  items: ourUserProfile[0]!.isHomeOwner ? [
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.home),
                      title: const Text('Home'),
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.add_box_outlined),
                      title: const Text('Create Post'),
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.person),
                      title: const Text('Profile'),
                    ),
                  ] :
                  [
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.home),
                      title: const Text('Home'),
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.add_box_outlined),
                      title: const Text('Create Post'),
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.all_inbox),
                      title: const Text('Roommate Posts'),
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.person),
                      title: const Text('Profile'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
