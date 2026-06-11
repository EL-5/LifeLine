import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationService {
  LocationService();

  Future<bool> hasPermission() async {
    final status = await Geolocator.checkPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  Future<bool> requestPermission() async {
    final status = await Geolocator.requestPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  Future<Position> getCurrentLocation() async {
    await requestPermission();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<double> calculateDistance(
    double lat1, double lng1,
    double lat2, double lng2,
  ) async {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Map<String, dynamic> positionToJson(Position position) {
    return {
      'lat': position.latitude,
      'lng': position.longitude,
      'address': '',
    };
  }
}