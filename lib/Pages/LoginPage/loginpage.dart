import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swiggyowner/Pages/HomePage/homePage.dart';
import '../../Utils/AppUtils.dart';
import '../../Utils/Network_Utils.dart';
import '../../Utils/Validate_utils.dart';
import '../SignUpPage/registrationpage.dart';
import 'package:http/http.dart' as http;

import '../Settings/changePassword.dart';
import 'forgot password/forgot_password.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? email;
  String? password;
  String message = '';
  int _login_btn_state = 0;
  bool _isObscured = true;

  Future<void> submit() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      String? email_error = Validate.validateEmail(email!);
      if (email_error != null) {
        AppUtil.showToast(context, email_error);
        return;
      }

      String? passwordError =
          Validate.requiredField(password ?? "Password required");
      if (passwordError != null) {
        AppUtil.showToast(context, passwordError);
        return;
      }
      await login(email: email!, password: password!);
    }
  }

  Future<void> login({required String email, required String password}) async {
    setState(() {
      _login_btn_state = 1;
    });

    Map<String, String> data = {
      'email': email,
      'password': password,
    };

    try {
      final response =
          await NetworkUtil.post(NetworkUtil.owner_login_url, body: data);

      setState(() {
        _login_btn_state = 0;
      });

      debugPrint("Status : ${response.statusCode}");
      debugPrint("Response body : ${response.body}");

      if (response.statusCode == 200) {
        var result = json.decode(response.body);

        if (result['success'] == true) {
          var data = result['data'];
          debugPrint("Data Model: ${data.toString()}");

          var token = data['user']['token'];
          await AppUtil.setToken(token);
          debugPrint("Token saved: $token");

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Homepage()));
        } else {
          AppUtil.showToast(
              context, result['message'] ?? "Login failed. Please try again.");
        }
      } else {
        var ErrorResult = json.decode(response.body);
        var error = ErrorResult['errors']['message'];
        AppUtil.showToast(context, error);
      }
    } catch (e) {
      setState(() {
        _login_btn_state = 0;
      });

      debugPrint("Login Error: $e");

      AppUtil.showToast(context,
          "Something went wrong. Please check your internet connection.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Section with Orange Background
              Container(
                color: Colors.orange,
                width: double.infinity,
                height: 250,
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    const Icon(
                      Icons.lock_outline,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome Back!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Email Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                    //controller: _emailController,
                    //keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email ID",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                    validator: (value) {
                      email = value!.trim();

                      if (email!.isEmpty) {
                        return 'Email is required';
                      } else if (!RegExp(r'^[\w.-]{3,}@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(email!)) {
                        return 'Enter a valid email address';
                      }

                      return null;
                    }),
              ),

              const SizedBox(height: 20),

              // Password Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                    //controller: _passwordController,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                          )),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                    validator: (value) {
                      password = value!.trim();

                      if (password!.isEmpty) {
                        return 'Password is required';
                      } else if (password!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    }),
              ),

              const SizedBox(height: 10),

              // Forgot Password
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                    },
                    child: Center(
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Login Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_login_btn_state == 0) {
                          submit();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _login_btn_state == 0
                        ? Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sign Up Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to Registration Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RegistrationScreen(), // Replace with your RegistrationScreen
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Terms and Conditions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "By logging in, you agree to our Terms & Conditions and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
