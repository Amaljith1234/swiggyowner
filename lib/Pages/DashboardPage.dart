import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swiggyowner/Pages/BankDetails/BankDetailsPAge.dart';
import 'package:swiggyowner/Pages/FoodDetailsAddEditPage.dart';
import 'package:swiggyowner/Pages/HomePage/homePage.dart';
import 'package:swiggyowner/Pages/OrderPage/OrderPage.dart';
import 'package:swiggyowner/Pages/ProfilePage.dart';
import '../Model/ProfileDetailsModel.dart';
import '../Utils/Network_Utils.dart';
import 'Hotel/HotelDetailsPage.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Profile> profile = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  Future<void> _fetchProfileDetails() async {
    try {
      var response = await NetworkUtil.get(NetworkUtil.PROFILE_DETAILS_URL);
      debugPrint('Fetch PROFILE DATA Status Code: ${response.statusCode}');
      debugPrint('Fetch PROFILE Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['data'] != null) {
          setState(() {
            profile = [Profile.fromJson(jsonData['data'])];
            isLoading = false;
          });
        } else {
          debugPrint("Error: API returned null data");
        }
      } else {
        debugPrint("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(color: Colors.white, fontSize: 25),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileCard(),
            SizedBox(height: 16),
            _buildDashboardOptions(),
            SizedBox(height: 20),
            // Text('Sales Overview',
            //     style: Theme.of(context).textTheme.headlineLarge),
            // SizedBox(height: 10),
            // Expanded(
            //   child: Center(
            //     child: Image.asset(
            //       'assets/images/SalesOverview.jpeg',
            //       width: 500,
            //       height: 500,
            //       fit: BoxFit.fill,
            //       errorBuilder: (context, error, stackTrace) {
            //         return Icon(Icons.error, size: 100);
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        if (profile.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(profileData: profile.first)),
          );
        }
      },
      child: Card(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, size: 25, color: Colors.white)),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.isNotEmpty ? profile.first.name ?? "No Name" : "Loading...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    profile.isNotEmpty ? profile.first.email ?? "No Email" : "",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    profile.isNotEmpty ? profile.first.phone ?? "No Phone" : "",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _dashboardCard(
            'Hotel Details',
            '',
            Icons.restaurant,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RestaurantDetailsPage()),
              );
            },
          ),
          _dashboardCard(
            'Bank Details',
            '',
            Icons.account_balance_sharp,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BankDetailsPage()),
              );
            },
          ),
          _dashboardCard(
            'Orders',
            '',
            Icons.shopping_cart,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Homepage(selectedIndex: 1,)),
              );
            },
          ),
          _dashboardCard(
            'Food',
            'Add food items',
            Icons.add_box_rounded,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditItemPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(String value, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: 150,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.orange),
              SizedBox(height: 10),
              Text(value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
