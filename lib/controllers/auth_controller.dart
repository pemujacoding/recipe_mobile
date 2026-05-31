import 'package:get/get.dart';
import '../services/session_service.dart';
import '../services/hive_service.dart';
import '../views/login_view.dart';
import '../views/main_wrapper.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var currentUsername = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    bool loginStatus = await SessionService.isLoggedIn();
    if (loginStatus) {
      isLoggedIn.value = true;
      currentUsername.value = await SessionService.getUsername();
    }
  }

  void login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Username dan password should not empty!",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    var userData = HiveService.getUserByUsername(username);

    if (userData != null) {
      if (userData['password'] == password) {
        await SessionService.saveSession(username);
        isLoggedIn.value = true;
        currentUsername.value = userData['username'];

        Get.snackbar(
          "Success",
          "Login succeed! Welcome ${currentUsername.value}",
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAll(() => MainWrapper());
      } else {
        Get.snackbar(
          "Error",
          "Incorrect assword",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        "Error",
        "Username not found",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void logout() async {
    await SessionService.clearSession();
    isLoggedIn.value = false;
    currentUsername.value = '';
    Get.offAll(() => LoginView());
  }
}
