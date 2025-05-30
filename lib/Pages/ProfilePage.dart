import 'package:flutter/material.dart';
import 'package:swiggyowner/Pages/Settings/SettingsPage.dart';
import 'package:swiggyowner/Utils/AppUtils.dart';

import '../Model/ProfileDetailsModel.dart';

class ProfilePage extends StatefulWidget {
  final Profile profileData;

  const ProfilePage({Key? key, required this.profileData}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Profile',
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(color: Colors.white, fontSize: 25),
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.orange,
                          size: 70,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // Handle image upload or change
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              widget.profileData.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            SizedBox(height: 5),
            Text(
              widget.profileData.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.orange[700],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileOption(Icons.phone, 'Phone Number',
                      widget.profileData.phone, () {}),
                  _buildProfileOption(
                      Icons.location_on, 'Address', 'Alappuzha, Kerala', () {}),
                  _buildProfileOption(Icons.calendar_today, 'Date of Birth',
                      '1 Jan 1990', () {}),
                  _buildProfileOption(
                    Icons.settings,
                    'Settings',
                    '',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    onPressed: () {
                      AppUtil.logout(context);
                    },
                    child: Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      IconData icon, String title, String value, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: Colors.orange),
          title: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.orange[800]),
          ),
          subtitle: value.isNotEmpty
              ? Text(value, style: TextStyle(color: Colors.orange[700]))
              : null,
          trailing:
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
        ),
        Divider(color: Colors.orange[200]),
      ],
    );
  }
}
