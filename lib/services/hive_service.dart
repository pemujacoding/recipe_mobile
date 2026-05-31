import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String userBoxName = 'userBox';
  static const String bookmarkBoxName = 'bookmarkBox';
  static const String scheduleBoxName = 'scheduleBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(userBoxName);
    await Hive.openBox(bookmarkBoxName);
    await Hive.openBox(scheduleBoxName);
  }

  static Box getUserBox() => Hive.box(userBoxName);
  static Box getBookmarkBox() => Hive.box(bookmarkBoxName);
  static Box getScheduleBox() => Hive.box(scheduleBoxName);

  static Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    var box = getUserBox();
    String key = username.toLowerCase();
    if (box.containsKey(key)) return false;
    await box.put(key, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'username': username,
      'email': email,
      'password': password,
    });
    return true;
  }

  static Map<String, dynamic>? getUserByUsername(String username) {
    var box = getUserBox();
    var user = box.get(username.toLowerCase());
    return user != null ? Map<String, dynamic>.from(user) : null;
  }

  static Future<bool> updateUser({
    required String oldUsername,
    required String newUsername,
    required String newEmail,
  }) async {
    var box = getUserBox();
    String oldKey = oldUsername.toLowerCase();
    String newKey = newUsername.toLowerCase();

    if (newKey != oldKey && box.containsKey(newKey)) return false;

    Map<String, dynamic> existing = Map<String, dynamic>.from(box.get(oldKey));
    Map<String, dynamic> updated = {
      ...existing,
      'username': newUsername,
      'email': newEmail,
    };

    if (newKey != oldKey) await box.delete(oldKey);
    await box.put(newKey, updated);
    return true;
  }

  static Future<bool> updatePassword({
    required String username,
    required String newPassword,
  }) async {
    try {
      var box = getUserBox();
      String key = username.toLowerCase();
      if (!box.containsKey(key)) return false;
      Map<String, dynamic> existing = Map<String, dynamic>.from(box.get(key));
      Map<String, dynamic> updated = {...existing, 'password': newPassword};
      await box.put(key, updated);
      return true;
    } catch (e) {
      print("Error updatePassword in Hive: $e");
      return false;
    }
  }

  static Future<bool> deleteUser(String username) async {
    try {
      var box = getUserBox();
      String key = username.toLowerCase();
      if (!box.containsKey(key)) return false;
      await box.delete(key);
      return true;
    } catch (e) {
      print("Error deleteUser in Hive: $e");
      return false;
    }
  }
  // ── BOOKMARK ──────────────────────────────────────────────────────────────

  static Future<void> addBookmark({
    required String username,
    required Map<String, dynamic> recipeJson,
  }) async {
    var box = getBookmarkBox();
    int recipeId = recipeJson['id'];
    await box.put('${username}_$recipeId', {
      'username': username,
      'recipe': recipeJson,
    });
  }

  static List<Map<String, dynamic>> getBookmarksByUser(String username) {
    var box = getBookmarkBox();
    List<Map<String, dynamic>> result = [];
    for (var key in box.keys) {
      if (key.toString().startsWith('${username}_')) {
        var item = box.get(key);
        if (item != null) {
          var data = Map<String, dynamic>.from(item);
          result.add(Map<String, dynamic>.from(data['recipe']));
        }
      }
    }
    return result;
  }

  static Future<void> deleteBookmark(String username, int recipeId) async {
    await getBookmarkBox().delete('${username}_$recipeId');
  }

  static bool isBookmarked(String username, int recipeId) {
    return getBookmarkBox().containsKey('${username}_$recipeId');
  }

  // ── SCHEDULE ──────────────────────────────────────────────────────────────

  static Future<void> addSchedule({
    required String username,
    required String title,
    required String mealType,
    required DateTime dateTime,
    String? notes,
  }) async {
    var box = getScheduleBox();
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put('${username}_$id', {
      'id': id,
      'username': username,
      'title': title,
      'mealType': mealType,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes ?? '',
    });
  }

  static List<Map<String, dynamic>> getSchedulesByUser(String username) {
    var box = getScheduleBox();
    List<Map<String, dynamic>> result = [];
    for (var key in box.keys) {
      if (key.toString().startsWith('${username}_')) {
        var item = box.get(key);
        if (item != null) result.add(Map<String, dynamic>.from(item));
      }
    }
    result.sort((a, b) => a['dateTime'].compareTo(b['dateTime']));
    return result;
  }

  static Future<void> deleteSchedule(String username, String id) async {
    await getScheduleBox().delete('${username}_$id');
  }

  static Future<void> updateSchedule({
    required String username,
    required String id,
    required String title,
    required String mealType,
    required DateTime dateTime,
    String? notes,
  }) async {
    await getScheduleBox().put('${username}_$id', {
      'id': id,
      'username': username,
      'title': title,
      'mealType': mealType,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes ?? '',
    });
  }
}
