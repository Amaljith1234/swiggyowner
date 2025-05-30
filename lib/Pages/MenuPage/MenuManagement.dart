import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swiggyowner/Pages/FoodDetailsAddEditPage.dart';
import '../../Model/FoodItemsModel.dart';
import '../../Utils/AppUtils.dart';
import '../../Utils/Network_Utils.dart';

class MenuManagementScreen extends StatefulWidget {
  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<FoodItem> menuItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  Future<void> _fetchFoodItems() async {
    try {
      var response = await NetworkUtil.get(NetworkUtil.FETCH_FOOD_ITEMS_URL);
      debugPrint(response.request.toString());
      debugPrint('Fetch Food Status Code: ${response.statusCode}');
      debugPrint('Fetch Food Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        FoodItemResponse foodResponse =
            FoodItemResponse.fromJson(jsonData['data']); // Extract `data`

        setState(() {
          menuItems = foodResponse.foodItems; // Assign fetched data to the list
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Management',
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(color: Colors.white)),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddEditItemPage()));
              },
              icon: Icon(Icons.add_chart, size: 30.0)),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : menuItems.isEmpty
              ? Center(
                  child: Text(
                  "No food items available.",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ))
              : ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return _buildDetailedMenuCard(item);
                  },
                ),
    );
  }

  Widget _buildDetailedMenuCard(FoodItem item) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Title
            Row(
              children: [
                item.images.isNotEmpty
                    ? Image.network(
                        item.images[0],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error,
                              size: 100); // Show error if image is not found
                        },
                      )
                    : SizedBox(
                        height: 100,
                        width: 100,
                        child: Icon(
                          Icons.fastfood,
                          size: 50,
                        ),
                      ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text(
                        item.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[500]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Price: ₹${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rating: --------',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Additional Info: Category, Ingredients, Availability
            Row(
              children: [
                Text(
                  'Category: ${item.category}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            Text(
              'Ingredients: non',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              'Preparation Time: non',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey[600]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.available == true ? 'Available' : 'Out of Stock',
                  style: TextStyle(
                    color: item.available == true ? Colors.green : Colors.red,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddEditItemPage(
                                      id: item.id,
                                      existingData: item.toJson(),
                                    )));
                        if (result == true) {
                          _fetchFoodItems(); // Refresh the menu list
                        }
                      },
                      child: Text('Edit'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        DeleteFoodItem(item.id);
                      },
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> DeleteFoodItem(String foodId) async {
    Map<String, String> data = {
      'foodId': foodId,
    };
    try {
      final response =
          await NetworkUtil.post(NetworkUtil.DELETE_FOOD_ITEM_URL, body: data);

      debugPrint("Removed Food body: ${response.body}");
      debugPrint("Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var result = json.decode(response.body);

        if (result['success'] == true) {
          setState(() {
            menuItems.removeWhere(
                (item) => item.id == foodId); // Remove item from the list
          });
          _fetchFoodItems();
          AppUtil.showToast(context, result['message']);
        } else {
          AppUtil.showToast(context, result['message']);
        }
      } else {
        AppUtil.showToast(context, "Something went wrong. Please try again.");
      }
    } catch (e) {
      debugPrint("Error: $e");
      AppUtil.showToast(
          context, "Failed to connect to server. Please try again.");
    }
  }
}
