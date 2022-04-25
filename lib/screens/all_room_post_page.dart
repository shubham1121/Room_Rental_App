import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/location.dart';
import 'package:room_rental_app/services/firebase_auth.dart';
import 'package:room_rental_app/utils/constants.dart';
import 'package:room_rental_app/utils/customised_app_bar.dart';
//import 'package:room_rental_app/services/location_services.dart'; ->  Do not call this page here
import 'package:room_rental_app/utils/device_size.dart';
import 'package:room_rental_app/utils/provider_location.dart';
import '../utils/all_post_list.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AllRoomPost extends StatefulWidget {
  const AllRoomPost({Key? key}) : super(key: key);

  @override
  _AllRoomPostState createState() => _AllRoomPostState();
}

class _AllRoomPostState extends State<AllRoomPost> {
  final AuthService _authService = AuthService();
  bool isLoading = true;
  bool init = true;
  late myLocation finalLocation;

  @override
  void initState() {
    super.initState();
    isLoading = true;
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await determinePosition(context).then((value) {});
  }

  Position? _currentPosition;
  String? _error;
  String city = "Gwalior";
  late myLocation _location;
  bool showFilteredData = false;
  Future<String> locationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return 'All Set';
  }

  myLocation get currentLocation => _location;

  Future<void> determinePosition(BuildContext context) async {
    String permission = await locationPermission();
    if (permission == 'All Set') {
      print('permission granted');
      Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.lowest,
              forceAndroidLocationManager: true)
          .then((Position position) {
        _currentPosition = position;
        print(_currentPosition);
        _getAddressFromPosition(context).then((value) {
          return;
        });
      }).catchError((e) {
        print(e);
      });
    } else {
      _error = 'Got Error';
    }
  }

  Future<void> _getAddressFromPosition(BuildContext context) async {
    try {
      if (_error != null || _currentPosition == null) {
        const SnackBar(content: Text('Permission Denied'));
        return;
      }
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);
      Placemark place = placemarks[0];
      //print(placemarks);
      //print(place);
      setState(() {
        _location = myLocation(
            pinCode: place.postalCode,
            city: place.locality,
            state: place.administrativeArea,
            country: place.country);
        city = place.locality!;
        isLoading = false;
      });

      Provider.of<ProviderLocation>(context, listen: false)
          .initializeCurrentLocation(_location);
      return;
    } catch (e) {
      print(e);
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    finalLocation =
        Provider.of<ProviderLocation>(context, listen: false).getLocation;
    if (finalLocation.city == '') {
      setState(() {
        print(finalLocation.city);
      });
    }
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CustomisedAppBar(
                mainHeading: 'Rooms Available',
                subHeading: 'Showing Recents First',
              isProfileSection: false,
            ),
            (isLoading)
                ? Center(
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Getting Current Location',
                          textStyle: TextStyle(
                            fontSize: displayWidth(context) * 0.055,
                            fontWeight: FontWeight.w500,
                            color: darkBlueColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          '${finalLocation.city}, ${finalLocation.country}',
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.06,
                            fontWeight: FontWeight.w600,
                            color: darkBlueColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.location_on_sharp),
                        color: darkBlueColor,
                        iconSize: displayWidth(context) * 0.07,
                        onPressed: () {
                          setState(() {
                            determinePosition(context);
                          });
                        },
                      ),
                    ],
                  ),
            isLoading
                ? const SizedBox(
                    width: 0,
                    height: 0,
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: lightGreyCardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: displayWidth(context) * 0.68,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          !showFilteredData
                              ? Card(
                            elevation: 15,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Text(
                                      'All Rooms',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            displayWidth(context) * 0.03,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  color: darkBlueColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15)),
                                )
                              :  GestureDetector(
                            onTap: (){
                              setState(() {
                                showFilteredData = !showFilteredData;
                              });
                            },
                                child: Text(
                                    'All Rooms',
                                    style: TextStyle(
                                      color: darkBlueColor,
                                      fontSize:
                                      displayWidth(context) * 0.03,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ),
                          // '${finalLocation.city} Rooms'
                          showFilteredData
                              ? Card(
                            elevation: 15,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Text(
                                '${finalLocation.city} Rooms',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                  displayWidth(context) * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            color: darkBlueColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(15)),
                          )
                              :  GestureDetector(
                            onTap: (){
                              setState(() {
                                showFilteredData = !showFilteredData;
                              });
                            },
                            child: Text(
                              '${finalLocation.city} Rooms',
                              style: TextStyle(
                                color: darkBlueColor,
                                fontSize:
                                displayWidth(context) * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            Expanded(
              child: AllPostList(
                showFilteredData: showFilteredData,
                city: finalLocation.city!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
