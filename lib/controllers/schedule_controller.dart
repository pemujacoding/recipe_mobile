import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class ScheduleController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();

  var schedules = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  final Map<String, IconData> mealIcons = {
    'Breakfast': Icons.wb_sunny_rounded,
    'Lunch': Icons.light_mode_rounded,
    'Dinner': Icons.nightlight_round,
    'Snack': Icons.cookie_rounded,
  };

  final Map<String, Color> mealColors = {
    'Breakfast': Colors.orange,
    'Lunch': Colors.amber,
    'Dinner': Colors.indigo,
    'Snack': Colors.green,
  };

  NotificationService notif = NotificationService();

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
    notif.initNotification();
  }

  void loadSchedules() {
    isLoading(true);
    final data = HiveService.getSchedulesByUser(
      _authCtrl.currentUsername.value,
    );
    schedules.assignAll(List<Map<String, dynamic>>.from(data));
    isLoading(false);
  }

  Future<void> addSchedule({
    required String title,
    required String mealType,
    required DateTime dateTime,
    required String notes,
  }) async {
    await HiveService.addSchedule(
      username: _authCtrl.currentUsername.value,
      title: title,
      mealType: mealType,
      dateTime: dateTime,
      notes: notes,
    );
    loadSchedules();
    Get.back();
    Get.snackbar(
      'Success',
      'Schedule added successfully',
      snackPosition: SnackPosition.BOTTOM,
    );

    notif.showNotification(
      '$title is added!',
      'You have $mealType plan at $dateTime',
    );
  }

  Future<void> updateSchedule({
    required String id,
    required String title,
    required String mealType,
    required DateTime dateTime,
    required String notes,
  }) async {
    await HiveService.updateSchedule(
      username: _authCtrl.currentUsername.value,
      id: id,
      title: title,
      mealType: mealType,
      dateTime: dateTime,
      notes: notes,
    );
    loadSchedules();
    Get.back();
    Get.snackbar(
      'Success',
      'Schedule updated successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deleteSchedule(String id) {
    Get.defaultDialog(
      title: 'Delete Schedule',
      middleText: 'Are you sure deleting this schedule?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        await HiveService.deleteSchedule(_authCtrl.currentUsername.value, id);
        Get.back(); // Tutup dialog konfirmasi
        loadSchedules(); // Refresh list
        Get.snackbar(
          'Deleted',
          'Schedule deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
