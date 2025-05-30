import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiggyowner/Pages/HomePage/homePage.dart';
import 'package:swiggyowner/Pages/LoginPage/loginpage.dart';

import '../../Utils/AppUtils.dart';
import '../../Utils/Network_Utils.dart';
import '../../Utils/Validate_utils.dart';

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? name;
  String? phone;
  String? hotelLocationCoordinatesLat;
  String? hotelLocationCoordinatesLag;
  String? hotelName;
  String? email;
  String? password;
  String message = '';
  int _login_btn_state = 0;
  bool _isObscured = true;

  LatLng? currentLocation;

  Future<void> fetchLocation() async {
    AppUtil.requestLocationPermission();
    try {
      LatLng location = await AppUtil.getCurrentLocation();
      setState(() {
        currentLocation = location;
      });
    } catch (e) {
      print("Error getting location: $e");
      AppUtil.showToast(context, "$e");
    }
  }

  Future<void> submit() async {
    fetchLocation();

    final form = _formKey.currentState;
    form!.validate();

    String? email_error = Validate.validateEmail(email!);
    if (email_error != null) {
      AppUtil.showToast(context, email_error);
      return;
    }

    String? password_error =
        Validate.requiredField(password ?? "Password required");
    if (password_error != null) {
      AppUtil.showToast(context, password_error);
      return;
    }

    signUp(
        email: email!,
        password: password!,
        name: name!,
        phone: phone!,
        hotelLocationCoordinatesLat: currentLocation!.latitude.toString(),
        hotelLocationCoordinatesLng: currentLocation!.longitude.toString(),
        hotelName: hotelName!);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String hotelLocationCoordinatesLat,
    required String hotelLocationCoordinatesLng,
    required String hotelName,
  }) async {
    setState(() {
      _login_btn_state = 1;
    });

    Map<String, String> data = {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'hotelLocationCoordinatesLat': hotelLocationCoordinatesLat,
      'hotelLocationCoordinatesLng': hotelLocationCoordinatesLng,
      'hotelName': hotelName,
    };
    // String body = json.encode(data);
    final response =
        await NetworkUtil.post(NetworkUtil.owner_signUp_url, body: data);

    setState(() {
      _login_btn_state = 0;
    });

    debugPrint("respopnse body : " + response.body);
    debugPrint("Status : " + response.statusCode.toString());

    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      if (result['success'] == true) {
        var data = result['data'];

        debugPrint("Data Model" + data.toString());

        //User.fromJson(data['user']);
        var token = data['user']['token'];
        await AppUtil.setToken(token);
        debugPrint("Token saved: " + token);

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Homepage()));
      } else {
        setState(() {
          _login_btn_state = 0;
        });
        AppUtil.showToast(context, result['message']);
      }
    } else {
      var ErrorResult = json.decode(response.body);
      var error = ErrorResult['errors']['message'];
      AppUtil.showToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchLocation();

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
                      Icons.person_add_alt_1_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Create Your Account",
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

              // Name Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: CustomInputDecoration(
                        labelText: 'Name', icon: Icon(Icons.perm_identity)),
                    validator: (value) {
                      name = value!.trim();

                      if (name!.isEmpty) {
                        return 'Name is required';
                      }else if (name!.length > 60){
                        return 'Name is too long';
                      }
                      return null;
                    }),
              ),

              const SizedBox(height: 20),

              // Email Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                    // keyboardType: TextInputType.emailAddress,
                    decoration: CustomInputDecoration(
                        labelText: 'Email ID',
                        icon: Icon(Icons.email_outlined)),
                    validator: (value) {
                      email = value!.trim();

                      if (email!.isEmpty) {
                        return 'Email is required';
                      } else if (!RegExp(r'^[\w.-]{3,}@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(email!)) {
                        return 'Enter a valid email address\n(Email must have at least 3 characters before @)';
                      }

                      return null;
                    }),
              ),

              const SizedBox(height: 20),

              //PHONE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: CustomInputDecoration(
                        labelText: 'Phone',
                        icon: Icon(Icons.phone_android_outlined)),
                    validator: (value) {
                      phone = value!.trim();

                      if (phone!.isEmpty) {
                        return 'Phone number is required';
                      }

                      return null;
                    }),
              ),

              const SizedBox(height: 20),

              // Password Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
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

              const SizedBox(height: 20),

              // Email Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                    // keyboardType: TextInputType.emailAddress,
                    decoration: CustomInputDecoration(
                        labelText: 'Hotel Name',
                        icon: Icon(Icons.restaurant_outlined)),
                    validator: (value) {
                      hotelName = value!.trim();

                      if (hotelName!.isEmpty) {
                        return 'Hotel Name is required';
                      }else if (hotelName!.length > 60){
                        return 'Hotel name is too long';
                      }

                      return null;
                    }),
              ),
              const SizedBox(height: 50),

              // Register Button
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
                            "REGISTER",
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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? then"),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LoginScreen(), // Replace with your RegistrationScreen
                        ),
                      );
                    },
                    child: Text(
                      "LOG IN",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              // Terms and Conditions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "By registering, you agree to our Terms & Conditions and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration CustomInputDecoration(
    {required String labelText, required Icon icon}) {
  return InputDecoration(
    labelText: labelText,
    prefixIcon: icon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.orange),
    ),
  );
}
