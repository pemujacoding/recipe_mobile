import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/hive_service.dart';
import '../services/session_service.dart';
import '../controllers/auth_controller.dart';
import '../views/login_view.dart';

class UserController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();

  var userData = <String, dynamic>{}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    isLoading(true);
    final data = HiveService.getUserByUsername(_authCtrl.currentUsername.value);
    if (data != null) {
      userData.assignAll(Map<String, dynamic>.from(data));
    }
    isLoading(false);
  }

  void create(String username, String email, String password) async {
    if (username.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "All forms should not be empty!",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Error",
        "Invalid email",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (HiveService.getUserByUsername(username) != null) {
      Get.snackbar(
        "Error",
        "Username is already exist",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    bool isSuccess = await HiveService.registerUser(
      username: username.trim(),
      email: email.trim(),
      password: password,
    );

    if (isSuccess) {
      Get.snackbar(
        "Succeed",
        "Your account is created, please log in",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.off(() => LoginView());
    } else {
      Get.snackbar(
        "Error",
        "Failed while creating account",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateProfile(String username, String email) async {
    final newUsername = username.trim();
    final newEmail = email.trim();

    if (newUsername.isEmpty || newEmail.isEmpty) {
      Get.snackbar(
        'Error',
        'Username and email should not be empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!GetUtils.isEmail(newEmail)) {
      Get.snackbar(
        'Error',
        'Invalid email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await HiveService.updateUser(
      oldUsername: _authCtrl.currentUsername.value,
      newUsername: newUsername,
      newEmail: newEmail,
    );

    if (!success) {
      Get.snackbar(
        'Error',
        'Username "$newUsername" is already exist',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await SessionService.saveSession(newUsername);
    _authCtrl.currentUsername.value = newUsername;

    loadUser();

    Get.back();

    Get.snackbar(
      'Success',
      'Profile has been updated',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updatePassword(String newPassword, String confirmPassword) async {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Password fields cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Password confirmation does not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final success = await HiveService.updatePassword(
      username: _authCtrl.currentUsername.value,
      newPassword: newPassword,
    );

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Password updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to update password',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteAccount() async {
    isLoading(true);
    final currentUsername = _authCtrl.currentUsername.value;

    final success = await HiveService.deleteUser(currentUsername);

    if (success) {
      await SessionService.clearSession();
      _authCtrl.currentUsername.value = '';
      isLoading(false);

      Get.offAll(() => LoginView());

      Get.snackbar(
        'Account Deleted',
        'Your account has been permanently removed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      isLoading(false);
      Get.snackbar(
        'Error',
        'Failed to delete account',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
