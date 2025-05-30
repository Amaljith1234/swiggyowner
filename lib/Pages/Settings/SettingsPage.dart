import 'package:flutter/material.dart';
import 'package:swiggyowner/Utils/AppUtils.dart';

import '../Hotel/HotelDetailsPage.dart';
import 'changePassword.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(color: Colors.white),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.business),
              title: Text('Business Information', style: customTitleStyle),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RestaurantDetailsPage()));
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.delivery_dining),
            //   title: Text('Delivery Radius', style: customTitleStyle),
            //   trailing: Icon(Icons.arrow_forward_ios),
            //   onTap: () {},
            // ),
            // ListTile(
            //   leading: Icon(Icons.policy),
            //   title: Text(
            //     'Policies',
            //     style: customTitleStyle,
            //   ),
            //   trailing: Icon(Icons.arrow_forward_ios),
            //   onTap: () {},
            // ),
            ListTile(
              leading: Icon(Icons.lock_reset),
              title: Text(
                'Change Password',
                style: customTitleStyle,
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage()));
              },
            ),
            ListTile(
                leading: Icon(Icons.login_outlined),
                title: Text(
                  'Logout',
                  style: customTitleStyle,
                ),
                trailing: Icon(Icons.logout),
                onTap: () {
                  AppUtil.logout(context);
                }),
          ],
        ),
      ),
    );
  }
}

TextStyle customTitleStyle = TextStyle(
  fontSize: 15.0,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);
