import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swiggyowner/Pages/LoginPage/loginpage.dart';
import '../../Utils/AppUtils.dart';
import '../../Utils/Network_Utils.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _loginBtnState = 0;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loginBtnState = 1;
      });

      Map<String, String> data = {
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
        'confirmPassword': _confirmPasswordController.text,
      };

      try {
        final response = await NetworkUtil.post(NetworkUtil.CHANGE_PASSWORD_URL, body: data);

        setState(() {
          _loginBtnState = 0;
        });

        debugPrint("Status: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");

        if (response.statusCode == 200) {
          var result = json.decode(response.body);
          if (result['success'] == true) {
            AppUtil.showToast(context, 'Password changed successfully!');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          } else {
            AppUtil.showToast(context, result['message'] ?? 'Failed to change password.');
          }
        } else {
          AppUtil.showToast(context, 'Error: Unable to change password.');
        }
      } catch (e) {
        setState(() {
          _loginBtnState = 0;
        });
        debugPrint("Change Password Error: $e");
        AppUtil.showToast(context, 'Something went wrong. Please check your internet connection.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Change Password')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Current Password'),
                validator: (value) => value!.isEmpty ? 'Enter current password' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                validator: (value) => value != _newPasswordController.text ? 'Passwords do not match' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginBtnState == 0 ? _changePassword : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _loginBtnState == 0
                    ? Text(
                  "CHANGE PASSWORD",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                )
                    : CircularProgressIndicator(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
