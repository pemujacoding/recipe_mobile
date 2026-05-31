import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxController {
  var locationResult = 'Fetching location...'.obs;
  var isLocationLoaded = false.obs;
  var isLoadingLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    isLoadingLocation(true);
    isLocationLoaded(false);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationResult('Layanan GPS di HP kamu mati. Silakan aktifkan GPS.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationResult('Location permission denied by user.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationResult(
          'Location permission permanently denied. Please enable it in settings.',
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city =
            place.locality ?? place.subAdministrativeArea ?? 'Unknown City';
        String region = place.administrativeArea ?? 'Unknown Region';
        String country = place.country ?? 'Unknown Country';

        locationResult('$city, $region, $country');
        isLocationLoaded(true);
      } else {
        locationResult('Coordinates found, but failed to parse address.');
      }
    } catch (e) {
      locationResult('Failed to get location: $e');
    } finally {
      isLoadingLocation(false);
    }
  }
}
