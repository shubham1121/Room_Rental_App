import 'package:flutter/material.dart';
import 'package:room_rental_app/models/location.dart';

class ProviderLocation extends ChangeNotifier{
  myLocation currentLocation = myLocation(state: '', city: '', pinCode: '', country: '');
  void initializeCurrentLocation(myLocation location)
  { currentLocation.country = location.country;
  currentLocation.city = location.city;
  currentLocation.pinCode = location.pinCode;
  currentLocation.state = location.state;
  notifyListeners();
  }
 myLocation get getLocation {
    return currentLocation;
  }
}
