import 'package:flutter/material.dart';

import 'InventoryList.dart';

class InventoryManagementScreen extends StatefulWidget {
  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final isLoading = false;
  final List<InventoryItem> inventoryItems = [
    InventoryItem(
      name: 'Pizza',
      stock: 50,
      price: 300.0,
      category: 'Main Course',
      minimumStockLevel: 20,
      status: 'Available',
      imageUrl: 'assets/images/pizza.jpg',
    ),
    InventoryItem(
      name: 'Burger',
      stock: 80,
      price: 150.0,
      category: 'Main Course',
      minimumStockLevel: 30,
      status: 'Available',
      imageUrl: 'assets/images/food5.jpg',
    ),
    InventoryItem(
      name: 'Pasta',
      stock: 60,
      price: 220.0,
      category: 'Main Course',
      minimumStockLevel: 15,
      status: 'Low Stock',
      imageUrl: 'assets/images/food4.jpg',
    ),
    InventoryItem(
      name: 'Ice Cream',
      stock: 30,
      price: 120.0,
      category: 'Dessert',
      minimumStockLevel: 10,
      status: 'Available',
      imageUrl: 'assets/images/food3.jpg',
    ),
    InventoryItem(
      name: 'Salad',
      stock: 25,
      price: 80.0,
      category: 'Appetizer',
      minimumStockLevel: 5,
      status: 'Out of Stock',
      imageUrl: 'assets/images/salad.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventory Management',
          style: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading == false
          ? Center(
              child: Text(
                "Currently Unavailable",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: inventoryItems.length,
              itemBuilder: (context, index) {
                final item = inventoryItems[index];
                return _buildInventoryCard(item, context);
              },
            ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item, BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.asset(
              item.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error,
                    size: 100); // Show error if image is not found
              },
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Stock: ${item.stock} units',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Price: ₹${item.price}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Category: ${item.category}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[500]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Status: ${item.status}',
                    style: TextStyle(
                      color: item.status == 'Out of Stock'
                          ? Colors.red
                          : item.status == 'Low Stock'
                              ? Colors.orange
                              : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
              onPressed: () {
                // Action for restocking (e.g., navigating to a restock page)
              },
            ),
          ],
        ),
      ),
    );
  }
}
