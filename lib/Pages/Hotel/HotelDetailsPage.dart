import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Model/RestaurantDetailsModel.dart';
import '../../Utils/Network_Utils.dart';
import 'HotelDetailsAddPage.dart';

class RestaurantDetailsPage extends StatefulWidget {
  const RestaurantDetailsPage({Key? key}) : super(key: key);

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  Restaurant? restaurant;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantDetails();
  }

  /// Fetch restaurant details
  Future<void> _fetchRestaurantDetails() async {
    try {
      final response = await NetworkUtil.get(NetworkUtil.RESTAURENT_DETAILS_URL);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['data'] != null) {
          setState(() {
            restaurant = Restaurant.fromJson(jsonData['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "No restaurant data found.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Error: ${response.statusCode} - ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Exception: $e";
        isLoading = false;
      });
    }
  }

  /// Check if restaurant data is complete
  bool _isRestaurantDataComplete() {
    if (restaurant == null) return false;

    return restaurant!.location.address.isNotEmpty &&
        restaurant!.location.city.isNotEmpty &&
        restaurant!.location.state.isNotEmpty &&
        restaurant!.location.country.isNotEmpty &&
        restaurant!.contactNumber.isNotEmpty &&
        restaurant!.openingHours.open.isNotEmpty &&
        restaurant!.openingHours.close.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hotel Details"),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : restaurant != null
          ? _buildRestaurantDetails()
          : const Center(child: Text("No details available")),

      /// FAB dynamically changes based on completeness
      floatingActionButton: restaurant != null
          ? FloatingActionButton(
        onPressed: () async {
          /// Navigate to AddUpdateHotelDetailsPage and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddUpdateHotelDetailsPage(
                restaurant: restaurant,
              ),
            ),
          );

          /// If the result is `true`, refresh the details
          if (result == true) {
            _fetchRestaurantDetails();
          }
        },
        backgroundColor: Colors.orange,
        child: Icon(
          _isRestaurantDataComplete() ? Icons.edit : Icons.add,
        ),
      )
          : null,
    );
  }

  /// Build restaurant details with null checks
  Widget _buildRestaurantDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            restaurant?.name ?? "No Name",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            restaurant?.description ?? "No description available",
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
          _buildDetailItem("Contact", restaurant?.contactNumber ?? "N/A"),
          _buildDetailItem("Location", restaurant?.location.address ?? "N/A"),
          _buildDetailItem("City", restaurant?.location.city ?? "N/A"),
          _buildDetailItem("State", restaurant?.location.state ?? "N/A"),
          _buildDetailItem("Country", restaurant?.location.country ?? "N/A"),
          const Divider(),
          _buildDetailItem(
            "Opening Hours",
            "${restaurant?.openingHours.open ?? 'N/A'} - ${restaurant?.openingHours.close ?? 'N/A'}",
          ),
          _buildDetailItem(
            "Average Rating",
            "${restaurant?.ratings.averageRating ?? 0.0} ⭐ (${restaurant?.ratings.totalRatings ?? 0} reviews)",
          ),
          const Divider(),
          const Text(
            "Images",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildImageGallery(restaurant?.images.hotelImages ?? []),
        ],
      ),
    );
  }

  /// Widget to build detail items with null checks
  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget to display image gallery with null safety
  Widget _buildImageGallery(List<String>? images) {
    if (images == null || images.isEmpty) {
      return const Center(
        child: Text("No images available"),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                images[index],
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 150),
              ),
            ),
          );
        },
      ),
    );
  }
}
