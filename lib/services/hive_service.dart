import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String userBoxName = 'userBox';
  static const String bookmarkBoxName = 'bookmarkBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(userBoxName);
    await Hive.openBox(bookmarkBoxName);
  }

  static Box getUserBox() => Hive.box(userBoxName);
  static Box getBookmarkBox() => Hive.box(bookmarkBoxName);

  static Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    var box = getUserBox();
    String key = username.toLowerCase();

    if (box.containsKey(key)) {
      return false;
    }

    Map<String, dynamic> userData = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'username': username,
      'email': email,
      'password': password,
    };

    await box.put(key, userData);
    return true;
  }

  static Map<String, dynamic>? getUserByUsername(String username) {
    var box = getUserBox();
    var user = box.get(username.toLowerCase());
    if (user != null) {
      return Map<String, dynamic>.from(user);
    }
    return null;
  }

  static Future<void> addBookmark({
    required String username,
    required Map<String, dynamic> recipeJson,
  }) async {
    var box = getBookmarkBox();
    int recipeId = recipeJson['id'];

    String key = '${username}_$recipeId';

    Map<String, dynamic> bookmarkData = {
      'username': username,
      'recipe': recipeJson,
    };

    await box.put(key, bookmarkData);
  }

  static List<Map<String, dynamic>> getBookmarksByUser(String username) {
    var box = getBookmarkBox();
    List<Map<String, dynamic>> userBookmarks = [];

    for (var key in box.keys) {
      if (key.toString().startsWith('${username}_')) {
        var item = box.get(key);
        if (item != null) {
          var data = Map<String, dynamic>.from(item);
          userBookmarks.add(Map<String, dynamic>.from(data['recipe']));
        }
      }
    }
    return userBookmarks;
  }

  static Future<void> deleteBookmark(String username, int recipeId) async {
    var box = getBookmarkBox();
    await box.delete('${username}_$recipeId');
  }

  static bool isBookmarked(String username, int recipeId) {
    var box = getBookmarkBox();
    return box.containsKey('${username}_$recipeId');
  }
}
