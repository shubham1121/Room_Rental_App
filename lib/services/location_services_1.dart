//
// import 'dart:async';
// import 'package:geocoding/geocoding.dart' show  Placemark, placemarkFromCoordinates;
// import 'package:location/location.dart' show Location, PermissionStatus;
// import 'package:room_rental_app/models/location.dart';
//
// class LocationService1 {
//   myLocation? _currentLocation;
//   Location location = Location();
//    StreamController<myLocation> locationController =
//   StreamController<myLocation>();
//
//   Stream<myLocation> get locationStream => locationController.stream;
//
//   LocationService1()
//   {
//     location.requestPermission().then((granted)  {
//       if (granted == PermissionStatus.granted) {
//         // If granted listen to the onLocationChanged stream and emit over our controller
//          location.onLocationChanged.listen((locationData)  {
//             locationController.add(_currentLocation!);
//         });
//       }
//     });
//   }
//
//   Future<myLocation?> getLocation() async {
//     try {
//       var userLocation = await location.getLocation();
//       List<Placemark> placemarks = await placemarkFromCoordinates(userLocation.longitude!, userLocation.latitude!);
//       Placemark place = placemarks[0];
//       _currentLocation = myLocation(
//         pinCode: place.postalCode,
//         city: place.locality,
//         state: place.administrativeArea,
//         country: place.country,
//       );
//     } on Exception catch (e) {
//       print('Could not get location: ${e.toString()}');
//     }
//
//     return _currentLocation;
//   }
//
//
//
// }