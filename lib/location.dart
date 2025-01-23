import 'package:geolocator/geolocator.dart';

class Location{
  Future<Position> getActualPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Permisos de ubicación denegados permanentemente.");
    }
    return await Geolocator.getCurrentPosition();
  }
}