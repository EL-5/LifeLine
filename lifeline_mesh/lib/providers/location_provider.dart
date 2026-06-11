import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/location_service.dart';

final currentLocationProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  try {
    return await locationService.getCurrentLocation();
  } catch (_) {
    return null;
  }
});