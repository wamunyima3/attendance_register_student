import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkAndRequestPermissions() async {
  // Check if permission is granted
  PermissionStatus locationPermissionStatus = await Permission.location.status;

  if (locationPermissionStatus != PermissionStatus.granted) {
    // Request permission
    await Permission.location.request();
  }
}

class LocationService {
  Future<Position> getCurrentLocation() async {
    // Request permission to access the user's location
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // If permission is still denied, throw an exception
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
  }
}

Future<Map<String, dynamic>> getLocation(BuildContext context) async {
  LocationService locationService = LocationService();
  try {
    // Check and request location permission
    await checkAndRequestPermissions();

    // Get current location
    Position position = await locationService.getCurrentLocation();
    double latitude = position.latitude;
    double longitude = position.longitude;

    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error getting current location'),
      ),
    );
    return {'error': 'Error while getting location'};
  }
}
