class FoodItemResponse {
  final String id;
  final String hotelId;
  final int totalItems;
  final List<FoodItem> foodItems;

  FoodItemResponse({
    required this.id,
    required this.hotelId,
    required this.totalItems,
    required this.foodItems,
  });

  factory FoodItemResponse.fromJson(Map<String, dynamic> json) {
    return FoodItemResponse(
      id: json['_id'],
      hotelId: json['hotelId'],
      totalItems: json['totalItems'],
      foodItems: (json['foodItems'] as List)
          .map((item) => FoodItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'hotelId': hotelId,
      'totalItems': totalItems,
      'foodItems': foodItems.map((item) => item.toJson()).toList(),
    };
  }
}

class FoodItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final int price;
  final bool available;
  final List<String> images;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.available,
    required this.images,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      price: json['price'],
      available: json['available'],
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'available': available,
      'images': images,
    };
  }
}
