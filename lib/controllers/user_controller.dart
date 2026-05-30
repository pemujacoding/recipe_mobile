import 'package:get/get.dart';
import 'package:recipe/services/hive_service.dart';
import '../views/login_view.dart';

class UserController {
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
      Get.snackbar("Error", "username is already exist");
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
}
