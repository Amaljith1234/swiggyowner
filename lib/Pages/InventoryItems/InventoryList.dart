class InventoryItem {
  final String name;
  final int stock;
  final double price;
  final String category;
  final int minimumStockLevel;
  final String status;
  final String imageUrl;

  InventoryItem({
    required this.name,
    required this.stock,
    required this.price,
    required this.category,
    required this.minimumStockLevel,
    required this.status,
    required this.imageUrl,
  });
}
