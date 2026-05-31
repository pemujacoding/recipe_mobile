import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_recommendation_controller.dart';
import '../services/location_service.dart';

class AiRecommendationView extends StatelessWidget {
  AiRecommendationView({super.key});

  // Inject kedua pengontrol secara terpisah
  final LocationService locationService = Get.put(LocationService());
  final AiRecommendationController aiController = Get.put(
    AiRecommendationController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 2,
        title: const Text(
          'AI Meal Advisor',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationCard(),
            const SizedBox(height: 20),

            const Text(
              'Reccomendation is based of your current location and these datas you need to input',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            Obx(
              () => DropdownButtonFormField<String>(
                value: aiController.selectedMeal.value.isEmpty
                    ? null
                    : aiController.selectedMeal.value,
                hint: const Text('Select Meal Type *'),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.category_rounded,
                    color: Colors.deepOrangeAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: aiController.mealTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) aiController.selectedMeal.value = val;
                },
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: aiController.calorieCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Target Calories (kcal) *',
                prefixIcon: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.deepOrangeAccent,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: aiController.notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notes / Preferences / Allergies (Optional)',
                prefixIcon: const Icon(
                  Icons.notes_rounded,
                  color: Colors.deepOrangeAccent,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: aiController.isLoadingAi.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.psychology_rounded),
                  label: Text(
                    aiController.isLoadingAi.value
                        ? 'Analyzing Data...'
                        : 'Get AI Recommendation',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: aiController.isLoadingAi.value
                      ? null
                      : () => aiController.getAiRecommendation(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildAiResponseSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.deepOrangeAccent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Current Location Status',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => locationService.isLocationLoaded.value
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                        )
                      : const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.amber,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Obx(
              () => locationService.isLoadingLocation.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrangeAccent,
                      ),
                    )
                  : Text(
                      locationService.locationResult.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: locationService.isLocationLoaded.value
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: locationService.isLocationLoaded.value
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.blueAccent,
                  ),
                  label: const Text(
                    'Reload Location',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  onPressed: locationService.isLoadingLocation.value
                      ? null
                      : () => locationService.getCurrentLocation(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section AI terhubung dengan AiRecommendationController
  Widget _buildAiResponseSection() {
    return Obx(() {
      if (aiController.aiResponse.value.isEmpty &&
          !aiController.isLoadingAi.value) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.deepOrangeAccent,
                  size: 20,
                ),
                SizedBox(width: 6),
                Text(
                  'AI Advisor Suggestion',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            aiController.isLoadingAi.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  )
                : Text(
                    aiController.aiResponse.value,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
          ],
        ),
      );
    });
  }
}
