import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

Future<LocationData> fetchCurrentLocation() async {
  var _currentLocation;
  var location = new Location();
  try {
    _currentLocation = await location.getLocation();
  } on PlatformException catch (e) {
    _currentLocation = null;
  }

  return _currentLocation;
}
