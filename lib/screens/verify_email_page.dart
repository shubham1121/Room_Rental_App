import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_rental_app/services/firebase_auth.dart';
import 'package:room_rental_app/utils/constants.dart';
import 'package:room_rental_app/utils/customised_app_bar.dart';
import 'package:room_rental_app/utils/device_size.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final AuthService _authService = AuthService();
  bool isEmailVerified = false;
  bool canResendEmail = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationMail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CustomisedAppBar(
                  mainHeading: 'Verify Email',
                  subHeading: 'Verification of Email for Authentic Users',
                  isProfileSection: false),
              SizedBox(
                height: displayWidth(context) * 0.4,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'A verification mail has been sent to your Email. Kindly logout first and then verify Email. You can resend email in every 30 seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: displayWidth(context) * 0.05,
                      color: darkBlueColor,
                    ),
                  ),
                  SizedBox(
                    height: displayWidth(context) * 0.09,
                  ),
                  ElevatedButton.icon(
                    onPressed: canResendEmail ? sendVerificationMail : null,
                    icon: const Icon(
                      Icons.mail,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Resend Email',
                      style: TextStyle(
                        fontSize: displayWidth(context) * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary:
                            canResendEmail ? darkBlueColor : darkGreyColor),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _authService.logout();
                      });
                    },
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: displayWidth(context) * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(primary: lightBlueColor),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future sendVerificationMail() async {
    try {
      setState(() {
        canResendEmail = false;
      });
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      debugPrint('Called Here');
      setState(() {
        Fluttertoast.showToast(
            msg: 'Email Sent Successfully',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green);
        debugPrint('called false');
      });
      await Future.delayed(const Duration(seconds: 60));
      setState(() {
        debugPrint('called true');
        canResendEmail = true;
      });
    } catch (e) {
      setState(() {
        Fluttertoast.showToast(
            msg: 'Too Many Attempts Try Again Later',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.redAccent);
        canResendEmail = true;
      });
      debugPrint(e.toString() + 'called catch error');
    }
  }
}
