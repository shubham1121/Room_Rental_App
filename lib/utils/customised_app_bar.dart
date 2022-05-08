import 'package:flutter/material.dart';
import 'package:room_rental_app/utils/constants.dart';
import 'package:room_rental_app/utils/device_size.dart';

class CustomisedAppBar extends StatelessWidget {
  final String mainHeading,subHeading;
  final bool isProfileSection;
   const CustomisedAppBar({required this.mainHeading,required this.subHeading, required this.isProfileSection,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(mainHeading,
          style: TextStyle(
            fontSize: displayWidth(context)*0.10,
            fontWeight: FontWeight.w800,
            color: isProfileSection ? Colors.white : darkBlueColor,
          ),
        ),
        Text(subHeading,
        style: TextStyle(
          fontSize: displayWidth(context)*0.045,
          fontWeight: FontWeight.w500,
          color: darkGreyColor,
        ),),
      ],
    );
  }
}
