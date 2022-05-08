import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/our_user.dart';
import 'package:room_rental_app/screens/authentication_screen.dart';
import 'package:room_rental_app/screens/home_page.dart';
import 'package:room_rental_app/screens/verify_email_page.dart';
import 'package:room_rental_app/services/database_firestore.dart';
import 'package:room_rental_app/services/location_services.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final LocationServices _locationServices = LocationServices();
  @override
  Widget build(BuildContext context) {
    _locationServices.determinePosition(context);
    final user = Provider.of<User?>(context);
    return user == null ?  const AuthenticationPage() : user.emailVerified ? MultiProvider(providers: [
      StreamProvider<List<OurUser?>?>.value(
        catchError: (_, __) => null,
        value: DatabaseService(user.uid).ourUserProfileData,
        initialData: null,
      ),
    ],
    child: const HomePage(),
    ): const VerifyEmailPage();
  }
}
