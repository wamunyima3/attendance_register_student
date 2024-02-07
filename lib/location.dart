import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
        desiredAccuracy: LocationAccuracy.high);
  }
}

Future<Map<String, dynamic>> getLocation(BuildContext context) async {
  LocationService locationService = LocationService();
  try {
    Position position = await locationService.getCurrentLocation();
    double latitude = position.latitude;
    double longitude = position.longitude;
    print('Latitude: $latitude, Longitude: $longitude');
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error getting current location: $e'),
      ),
    );
    return {'error': e.toString()};
  }
}
