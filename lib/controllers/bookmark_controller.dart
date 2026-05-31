import 'package:get/get.dart';
import '../models/recipe_model.dart';
import '../services/hive_service.dart';
import 'auth_controller.dart';

class BookmarkController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  var bookmarkedRecipes = <Recipe>[].obs;
  var isLoading = false.obs;

  String get _currentUsername => _authController.currentUsername.value;

  @override
  void onInit() {
    super.onInit();
    fetchBookmarks();
  }

  void fetchBookmarks() {
    try {
      isLoading(true);
      List<Map<String, dynamic>> rawData = HiveService.getBookmarksByUser(
        _currentUsername,
      );
      List<Recipe> recipes = rawData
          .map((json) => Recipe.fromJson(json))
          .toList();
      bookmarkedRecipes.assignAll(recipes);
    } catch (e) {
      Get.snackbar("Error", "Failed to load bookmark: $e");
    } finally {
      isLoading(false);
    }
  }

  bool isRecipeBookmarked(int recipeId) {
    return HiveService.isBookmarked(_currentUsername, recipeId);
  }

  void toggleBookmark(Recipe recipe) async {
    if (isRecipeBookmarked(recipe.id)) {
      await HiveService.deleteBookmark(_currentUsername, recipe.id);

      bookmarkedRecipes.removeWhere((item) => item.id == recipe.id);

      Get.snackbar(
        "Bookmark",
        "${recipe.name} removed from bookmark",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      await HiveService.addBookmark(
        username: _currentUsername,
        recipeJson: recipe.toJson(),
      );

      bookmarkedRecipes.add(recipe);

      Get.snackbar(
        "Bookmark",
        "${recipe.name} added to bookmark!",
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    bookmarkedRecipes.refresh();
  }
}
