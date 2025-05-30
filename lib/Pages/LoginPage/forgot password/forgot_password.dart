import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../Utils/AppUtils.dart';
import '../../../Utils/Network_Utils.dart';
import '../../SignUpPage/registrationpage.dart';
import 'new_password.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Forgot Password",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Enter Email Address", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "example@gmail.com",hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                  minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                onPressed: isLoading ? null : _sendEmail,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send", style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to login"),
              ),
              const Text("Don't have an account?"),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                ),
                child: const Text("Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Method to send email and handle API response
  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final String email = emailController.text.trim();
    final Map<String, String> data = {'email': email, 'role' : 'owner'};

    try {
      final response = await NetworkUtil.post(
        NetworkUtil.FORGOT_PASSWORD_URL,
        body: data,
      );

      debugPrint("Response: ${response.body}");
      debugPrint("Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result['success'] == true) {
          AppUtil.showToast(context, "OTP sent successfully!");

          // ✅ Navigate to VerificationPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPasswordPage(email: email)),
          );
        } else {
          AppUtil.showToast(context, result['message']);
        }
      } else {
        var errorResult = json.decode(response.body);
        AppUtil.showToast(context, "${errorResult['message']} : Try again!");
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
}
