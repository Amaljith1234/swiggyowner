import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Model/OrderModel.dart';
import '../../Utils/Network_Utils.dart';
import 'orderCard.dart';

class OrdersScreen extends StatefulWidget {
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Fetch orders when the screen is initialized
  }

  Future<void> fetchOrders() async {
    try {
      final response = await NetworkUtil.get(NetworkUtil.ORDER_LIST_URL);

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('data') &&
            responseData['data'] != null &&
            responseData['data'].containsKey('orders') &&
            responseData['data']['orders'] is List) {

          final List<dynamic> ordersData = responseData['data']['orders'] ?? [];
          debugPrint("Raw Orders Data: ${jsonEncode(ordersData)}");

          setState(() {
            _orders = ordersData.map((order) => OrderModel.fromJson(order)).toList();
            _isLoading = false;
          });

          debugPrint("✅ Successfully loaded ${_orders.length} orders.");
        } else {
          debugPrint("⚠️ Unexpected response format: ${response.body}");
        }
      } else {
        debugPrint("❌ Failed to load orders: Status Code ${response.statusCode}");
      }
    } catch (error, stackTrace) {
      debugPrint("❌ Error fetching orders: $error");
      debugPrint("🔍 StackTrace: $stackTrace");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Text(
                    "No Order Found",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return DetailedOrderCard(
                      orderId: order.id,
                      customerName: 'customer name',
                      customerAddress:
                          '${order.address.street}, ${order.address.city}, ${order.address.state}',
                      orderTime: order.orderDate,
                      orderItems: order.items.map((item) => {
                        "name": item.foodDetails.isNotEmpty ? item.foodDetails[0].name : "Unknown Food",
                        "quantity": item.qty,
                        "price": item.price
                      }).toList(),
                      totalAmount: order.totalAmount.toInt(),
                      status: order.status,
                      onAccept: () => print('Order Accepted'),
                      onMarkPrepared: () => print('Order Marked as Prepared'),
                      onDispatch: () => print('Order Dispatched'),
                    );
                  },
                ),
    );
  }
}
