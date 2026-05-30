class Recipe {
  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final int caloriesPerServing;
  final List<String> tags;
  final int userId;
  final String image;
  final double rating;
  final int reviewCount;
  final List<String> mealType;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    required this.caloriesPerServing,
    required this.tags,
    required this.userId,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.mealType,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : [],
      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'])
          : [],
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 0,
      cookTimeMinutes: json['cookTimeMinutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? '',
      cuisine: json['cuisine'] as String? ?? '',
      caloriesPerServing: json['caloriesPerServing'] as int? ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      userId: json['userId'] as int? ?? 0,
      image: json['image'] as String? ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      mealType: json['mealType'] != null
          ? List<String>.from(json['mealType'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'cuisine': cuisine,
      'caloriesPerServing': caloriesPerServing,
      'tags': tags,
      'userId': userId,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'mealType': mealType,
    };
  }
}
