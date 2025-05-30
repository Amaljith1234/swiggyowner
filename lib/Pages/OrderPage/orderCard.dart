import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Utils/AppUtils.dart';
import '../../Utils/Network_Utils.dart';

class DetailedOrderCard extends StatefulWidget {
  final String orderId;
  final String customerName;
  final String customerAddress;
  final String orderTime;
  final List<Map<String, dynamic>> orderItems;
  final int totalAmount;
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onMarkPrepared;
  final VoidCallback onDispatch;

  const DetailedOrderCard({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.customerAddress,
    required this.orderTime,
    required this.orderItems,
    required this.totalAmount,
    required this.status,
    required this.onAccept,
    required this.onMarkPrepared,
    required this.onDispatch,
  }) : super(key: key);

  @override
  State<DetailedOrderCard> createState() => _DetailedOrderCardState();
}

class _DetailedOrderCardState extends State<DetailedOrderCard> {
  bool _isProcessing = false;



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Time
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID: ${widget.orderId}',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.orderTime.substring(0,10),
                  style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Customer Details
            Row(
              children: [
                Icon(Icons.person, color: theme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.customerName,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: theme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.customerAddress,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Order Items List
            Text(
              'Order Items:',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...widget.orderItems.map((item) => _buildOrderItem(item)),

            const Divider(height: 20, thickness: 1),

            // Total Amount and Status
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: ₹${widget.totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Status: ${widget.status}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getStatusColor(widget.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProcessButton(
                      label: "Prepare Order",
                      onPressed: () => _updateOrderStatus(NetworkUtil.PREPARE_ORDER_URL),
                    ),
                    _buildProcessButton(
                      label: "Order Completed",
                      onPressed: () => _updateOrderStatus(NetworkUtil.COMPLETE_ORDER_URL),
                    ),
                  ],
                ),
                _buildActionButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build order items
  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${item['name']} x ${item['quantity']}',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '₹${item['price']}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Prepared':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Helper function to build action buttons
  Widget _buildProcessButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      child: Text(label),
    );
  }

  // Simplified Action Button
  Widget _buildActionButton() {
    String buttonText = '';
    Color buttonColor = Colors.grey;
    VoidCallback? onPressed;

    switch (widget.status) {
      case 'Pending':
        buttonText = 'Accept';
        buttonColor = Colors.green;
        onPressed = widget.onAccept;
        break;
      case 'Accepted':
        buttonText = 'Mark Prepared';
        buttonColor = Colors.orange;
        onPressed = widget.onMarkPrepared;
        break;
      case 'Prepared':
        buttonText = 'Dispatch';
        buttonColor = Colors.blue;
        onPressed = widget.onDispatch;
        break;
      default:
        return const SizedBox(); // No button for other statuses
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
      child: Text(buttonText),
    );
  }

  // Function to update order status
  Future<void> _updateOrderStatus(String apiUrl) async {
    setState(() => _isProcessing = true);

    Map<String, String> data = {'orderId': widget.orderId};

    try {
      final response = await NetworkUtil.post(apiUrl, body: data);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Order updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Failed to update order.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
