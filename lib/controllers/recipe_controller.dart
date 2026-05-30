import 'package:get/get.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';

class RecipeController extends GetxController {
  var isLoading = true.obs;
  var allRecipes =
      <Recipe>[].obs; // Berfungsi sebagai backup data asli dari API
  var recipeList =
      <Recipe>[].obs; // Berfungsi sebagai data dinamis yang tampil di UI

  @override
  void onInit() {
    fetchRecipes();
    super.onInit();
  }

  void fetchRecipes() async {
    try {
      isLoading(true);
      var recipes = await ApiService.fetchRecipes();

      //  PENTING: Isi keduanya di sini
      allRecipes.assignAll(recipes); // Simpan master data resep ke backup
      recipeList.assignAll(recipes); // Tampilkan juga ke UI untuk pertama kali
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void filterRecipes(String query) {
    if (query.isEmpty) {
      // Jika kolom pencarian kosong, kembalikan data dari backup asli
      recipeList.assignAll(allRecipes);
    } else {
      // Lakukan pencarian dari allRecipes (master data) agar pencarian selalu akurat
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
