import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/our_user.dart';
import 'package:room_rental_app/models/post_data.dart';
import 'package:room_rental_app/models/roommate_post.dart';
import 'package:room_rental_app/services/database_firestore.dart';
import 'package:room_rental_app/services/firebase_auth.dart';
import 'package:room_rental_app/utils/constants.dart';
import 'package:room_rental_app/utils/customised_app_bar.dart';

import '../utils/my_post.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return MultiProvider(
      providers: [
        StreamProvider<List<PostData?>?>.value(
          catchError: (_, err) {
            debugPrint(err.toString() + 'PostData');
            debugPrint('got List<PostData>');
            return null;
          },
          value: DatabaseService(user!.uid).userPostData,
          initialData: null,
        ),
        StreamProvider<List<RoommatePostData?>?>.value(
          catchError: (_, err) {
            debugPrint(err.toString() + 'Roommate PostData');
            debugPrint('got List<RoommatePostData>');
            return null;
          },
          value: DatabaseService(user.uid).userRoommatePostData,
          initialData: null,
        ),
        StreamProvider<List<OurUser?>?>.value(
          value: DatabaseService(user.uid).ourUserProfileData,
          initialData: null,
          catchError: (_, err) {
            debugPrint(err.toString() + 'Our User');
            debugPrint('got List<OurUser>');
            return null;
          },
        )
      ],
      child: const SafeArea(
        child: Scaffold(
          body: MyPostList(),
        ),
      ),
    );
  }
}
