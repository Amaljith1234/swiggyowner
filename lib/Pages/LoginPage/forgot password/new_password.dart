import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../Utils/Network_Utils.dart';
import '../../../Utils/AppUtils.dart';
import '../loginpage.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController pinController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isButtonEnabled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    pinController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  /// ✅ Form Validation
  void _validateForm() {
    setState(() {
      isButtonEnabled = pinController.text.length == 6 &&
          passwordController.text.length >= 5 &&
          passwordController.text == confirmPasswordController.text;
    });
  }

  /// ✅ API Call: Verify OTP + Reset Password
  Future<void> _submit() async {
    if (!isButtonEnabled) return;

    setState(() => isLoading = true);

    final Map<String, String> data = {
      'email': widget.email, // Include email in the API request
      'otp': pinController.text,
      'newPassword': passwordController.text,
      'confirmPassword': confirmPasswordController.text,
      'role':'owner'
    };

    try {
      final response = await NetworkUtil.post(
        NetworkUtil.RESET_PASSWORD_WITH_OTP_URL,
        // Replace with your API endpoint
        body: data,
      );

      debugPrint("Response: ${response.body}");
      debugPrint("Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result['success'] == true) {
          AppUtil.showToast(context, "Password reset successfully!");

          /// ✅ Navigate back to login or home page
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        } else {
          AppUtil.showToast(context, result['message']);
        }
      } else {
        var errorResult = json.decode(response.body);
        AppUtil.showToast(context, "${errorResult['message']}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      AppUtil.showToast(context, "An error occurred. Check your connection.");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ✅ Display Email
              Text(
                "Reset Password for",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                "${widget.email}",
                style: const TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              /// ✅ OTP Input
              const Text("Enter Verification Code",
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Pinput(
                length: 6,
                controller: pinController,
                defaultPinTheme: PinTheme(
                  width: 60,
                  height: 60,
                  textStyle: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              /// ✅ New Password Input
              const Text("Enter New Password", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "At least 6 characters",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),

              /// ✅ Confirm Password Input
              const Text("Confirm Password", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
              ),
              const SizedBox(height: 30),

              /// ✅ Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: isButtonEnabled ? _submit : null,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Reset Password",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
