import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends StatelessWidget {
  ScheduleView({super.key});

  final ScheduleController scheduleCtrl = Get.put(ScheduleController());

  void _showAddEditDialog(
    BuildContext context, {
    Map<String, dynamic>? existing,
  }) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final notesCtrl = TextEditingController(text: existing?['notes'] ?? '');

    // Inisialisasi Rx secara eksplisit agar aman dari NoSuchMethodError
    final RxString selectedMeal = RxString(
      existing?['mealType'] ?? scheduleCtrl.mealTypes[0],
    );
    final Rx<DateTime> selectedDate = Rx<DateTime>(
      existing != null ? DateTime.parse(existing['dateTime']) : DateTime.now(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? 'Add Meal Schedule' : 'Edit Schedule',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Schedule Title',
                  prefixIcon: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.deepOrangeAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepOrangeAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Obx Lokal untuk Dropdown Kategori
              Obx(
                () => DropdownButtonFormField<String>(
                  value: selectedMeal.value,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(
                      Icons.category_rounded,
                      color: Colors.deepOrangeAccent,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.deepOrangeAccent,
                        width: 2,
                      ),
                    ),
                  ),
                  items: scheduleCtrl.mealTypes
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedMeal.value = val;
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Obx Lokal untuk DateTime Picker
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.deepOrangeAccent,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (date == null) return;

                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.fromDateTime(selectedDate.value),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.deepOrangeAccent,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (time == null) return;

                  selectedDate.value = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.deepOrangeAccent,
                      ),
                      const SizedBox(width: 10),
                      Obx(
                        () => Text(
                          DateFormat(
                            'dd MMM yyyy – HH:mm',
                          ).format(selectedDate.value),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: const Icon(
                    Icons.notes_rounded,
                    color: Colors.deepOrangeAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepOrangeAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Schedule title should not be empty',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    if (existing == null) {
                      scheduleCtrl.addSchedule(
                        title: titleCtrl.text.trim(),
                        mealType: selectedMeal.value,
                        dateTime: selectedDate.value,
                        notes: notesCtrl.text.trim(),
                      );
                    } else {
                      scheduleCtrl.updateSchedule(
                        id: existing['id'],
                        title: titleCtrl.text.trim(),
                        mealType: selectedMeal.value,
                        dateTime: selectedDate.value,
                        notes: notesCtrl.text.trim(),
                      );
                    }
                  },
                  child: Text(
                    existing == null ? 'Save Schedule' : 'Update Schedule',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    scheduleCtrl.loadSchedules();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 2,
        title: const Text(
          'Meal Schedule',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () => _showAddEditDialog(context),
      ),
      body: Obx(() {
        if (scheduleCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrangeAccent),
          );
        }

        if (scheduleCtrl.schedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No meal schedule yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + button to add new schedule',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          itemCount: scheduleCtrl.schedules.length,
          itemBuilder: (context, index) {
            final item = scheduleCtrl.schedules[index];
            final dt = DateTime.parse(item['dateTime']);
            final color =
                scheduleCtrl.mealColors[item['mealType']] ??
                Colors.deepOrangeAccent;
            final icon =
                scheduleCtrl.mealIcons[item['mealType']] ?? Icons.restaurant;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color),
                ),
                title: Text(
                  item['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.label_rounded, size: 13, color: color),
                        const SizedBox(width: 4),
                        Text(
                          item['mealType'],
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy').format(dt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 17),
                            Text(
                              DateFormat('HH:mm').format(dt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (item['notes'] != null &&
                        item['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.notes_rounded,
                            size: 13,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item['notes'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: Colors.deepOrangeAccent,
                      ),
                      onPressed: () =>
                          _showAddEditDialog(context, existing: item),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => scheduleCtrl.deleteSchedule(item['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
