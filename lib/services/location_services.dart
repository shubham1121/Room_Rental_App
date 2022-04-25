import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/location.dart';
import 'package:room_rental_app/utils/provider_location.dart';

class LocationServices {
  Position? _currentPosition;
  String? _error;
  late myLocation _location;
  Future<String> locationPerimission() async {
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
    String permission = await locationPerimission();
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
      _location = myLocation(
          pinCode: place.postalCode,
          city: place.locality,
          state: place.administrativeArea,
          country: place.country);
      Provider.of<ProviderLocation>(context, listen: false)
          .initializeCurrentLocation(_location);
      myLocation l =
          Provider.of<ProviderLocation>(context, listen: false).getLocation;
      print("Current city = ${l.city}");
      return;
    } catch (e) {
      print(e);
    }
    return;
  }
}
