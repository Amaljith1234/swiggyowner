import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart' as prefix;
import 'package:permission_handler/permission_handler.dart';
import 'package:swiggyowner/Pages/LoginPage/loginpage.dart';

import 'Pages/HomePage/homePage.dart';
import 'Utils/AppUtils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await AppUtil.requestLocationPermission();
  runApp(RestaurantOwnerApp());
}

class RestaurantOwnerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant Owner App',
      theme: ThemeData(
        // Define the primary theme color
        primaryColor: Colors.orange, // Specific primary color if needed
        hintColor: Colors.amber, // Secondary color for accents
        scaffoldBackgroundColor: Colors.orange, // Background color for screens
        primarySwatch: Colors.orange,
        fontFamily: GoogleFonts.alata().fontFamily,
        textTheme: TextTheme(
          displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          displayLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(fontSize: 14, color: Colors.grey[600]),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[500]),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.orange, // AppBar color
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: MobileScreen(), // Your app's entry point
    );
  }
}

class MobileScreen extends StatefulWidget {
  const MobileScreen({Key? key}) : super(key: key);

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  Widget _initialScreen = const Scaffold(body: Center(child: CircularProgressIndicator()));

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    String? token = await AppUtil.getToken();

    setState(() {
      _initialScreen = token != null ? Homepage() : LoginScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _initialScreen;
  }
}

