class OrderModel {
  final String id;
  final String cartId;
  final String customerId;
  final String restaurantId;
  final Address address;
  final String phone;
  final double totalAmount;
  final String orderDate;
  final String paidThrough;
  final String status;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.cartId,
    required this.customerId,
    required this.restaurantId,
    required this.address,
    required this.phone,
    required this.totalAmount,
    required this.orderDate,
    required this.paidThrough,
    required this.status,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'],
      cartId: json['cartId'],
      customerId: json['customerId'],
      restaurantId: json['restaurantId'],
      address: Address.fromJson(json['address']),
      phone: json['phone'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      orderDate: json['orderDate'],
      paidThrough: json['paidThrough'],
      status: json['status'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipCode;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zipCode'],
    );
  }
}

class OrderItem {
  final String id;
  final int qty;
  final double price;
  final List<FoodDetails> foodDetails;

  OrderItem({
    required this.id,
    required this.qty,
    required this.price,
    required this.foodDetails,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'],
      qty: json['qty'],
      price: (json['price'] as num).toDouble(),
      foodDetails: (json['foodDetails'] as List)
          .map((food) => FoodDetails.fromJson(food))
          .toList(),
    );
  }
}

class FoodDetails {
  final String name;
  final String description;
  final String category;

  FoodDetails({
    required this.name,
    required this.description,
    required this.category,
  });

  factory FoodDetails.fromJson(Map<String, dynamic> json) {
    return FoodDetails(
      name: json['name'],
      description: json['description'],
      category: json['category'],
    );
  }
}

