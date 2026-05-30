import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class LbsService {
  // State reaktif untuk menyimpan teks lokasi terkini
  final RxString _locationResult = 'Lokasi belum dicek'.obs;
  final RxBool _isLoadingLocation = false.obs;

  // FUNGSI LBS: Mengambil koordinat GPS HP
  Future<void> _getCurrentLocation() async {
    _isLoadingLocation.value = true;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationResult.value = 'Izin lokasi ditolak oleh pengguna.';
          _isLoadingLocation.value = false;
          return;
        }
      }

      // Ambil posisi GPS saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Simpan koordinat ke dalam string untuk ditampilkan di UI
      _locationResult.value =
          'Lat: ${position.latitude}\nLong: ${position.longitude}';
    } catch (e) {
      _locationResult.value = 'Gagal mendapatkan lokasi: $e';
    } finally {
      _isLoadingLocation.value = false;
    }
  }

  Widget locationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.location_on_rounded, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  'Fitur LBS (Lokasi Terkini)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(
              () => Text(
                _locationResult.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isLoadingLocation.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.gps_fixed_rounded,
                          color: Colors.blueAccent,
                        ),
                  label: Text(
                    _isLoadingLocation.value
                        ? 'Mengambil GPS...'
                        : 'Dapatkan Koordinat',
                  ),
                  onPressed: _isLoadingLocation.value
                      ? null
                      : _getCurrentLocation,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
