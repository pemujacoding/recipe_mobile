import 'package:get/get.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';

class RecipeController extends GetxController {
  var isLoading = true.obs;
  var allRecipes = <Recipe>[].obs;
  var recipeList = <Recipe>[].obs;

  @override
  void onInit() {
    fetchRecipes();
    super.onInit();
  }

  void fetchRecipes() async {
    try {
      isLoading(true);
      var recipes = await ApiService.fetchRecipes();

      allRecipes.assignAll(recipes);
      recipeList.assignAll(recipes);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void filterRecipes(String query) {
    if (query.isEmpty) {
      recipeList.assignAll(allRecipes);
    } else {
      recipeList.assignAll(
        allRecipes
            .where(
              (recipe) =>
                  recipe.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList(),
      );
    }
  }
}
