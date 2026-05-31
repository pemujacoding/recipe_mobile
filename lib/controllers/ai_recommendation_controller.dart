import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../services/location_service.dart';

class AiRecommendationController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  var selectedMeal = ''.obs;
  var aiResponse = ''.obs;
  var isLoadingAi = false.obs;

  final calorieCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  final String _apiKey = 'AIzaSyANimtstu5ybkatjMoX9LvEvRAz3V0xJDk';
  final String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent";

  Future<void> getAiRecommendation() async {
    if (selectedMeal.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a Meal Type!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (calorieCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please input your Target Calories!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (!_locationService.isLocationLoaded.value) {
      Get.snackbar(
        'Location Missing',
        'Cannot get recommendations without a valid location. Please reload your GPS.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber,
        colorText: Colors.black,
      );
      return;
    }

    isLoadingAi(true);
    aiResponse(''); // Reset respon lama

    try {
      final double calories = double.tryParse(calorieCtrl.text.trim()) ?? 0.0;

      final prompt = _buildPrompt(
        location: _locationService.locationResult.value,
        mealType: selectedMeal.value,
        calories: calories,
        notes: notesCtrl.text.trim(),
      );

      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        aiResponse(data['candidates'][0]['content']['parts'][0]['text']);
      } else {
        aiResponse("AI Assistant is currently busy, please try again later.");
      }
    } catch (e) {
      aiResponse("Connection failed: $e");
    } finally {
      isLoadingAi(false);
    }
  }

  String _buildPrompt({
    required String location,
    required String mealType,
    required double calories,
    required String notes,
  }) {
    return """
You are an expert AI Nutritionist and Professional Chef Assistant.
Recommend a perfect meal option to eat or cook based on the following user data:

- Current Location: $location (Consider local culinary culture, popular available ingredients, or typical weather conditions here)
- Meal Type: $mealType
- Target Calories: $calories kcal
- Additional Notes/Restrictions: ${notes.isEmpty ? 'None' : notes}

Please output your response strictly using this Markdown format:

### 🍽️ Recommended Meal
**[Insert Meal Name Here]** *[Short catchy 1-sentence description of the dish]*

---

### 📊 Nutritional Breakdown (Estimate)
* **Calories:** ~[X] kcal
* **Carbs / Protein / Fats:** [X]g / [X]g / [X]g

---

### 💡 Why this fits you?
[Provide 2-3 sentences explaining why this suits their location ($location), matches their targeted $calories kcal, and respects their custom notes].

---

### 🍳 Quick Cooking / Sourcing Tip
[Give a brief tip on how to cook it easily or where to buy it locally].

Respond in English, be professional, highly structured, and to the point. No conversational filler before the markdown headings.
""";
  }

  @override
  void onClose() {
    calorieCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }
}
