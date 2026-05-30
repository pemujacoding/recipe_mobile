import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import '../views/login_view.dart';
import '../views/main_wrapper.dart';
import 'controllers/auth_controller.dart';
import '../services/hive_service.dart';
import '../services/session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  Get.put(AuthController());

  bool loggedIn = await SessionService.isLoggedIn();

  runApp(MainApp(isLoggedIn: loggedIn));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Responsi App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? MainWrapper() : LoginView(),
    );
  }
}
