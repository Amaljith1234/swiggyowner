import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Map/map_picker.dart';
import '../../Model/RestaurantDetailsModel.dart';
import '../../Utils/AppUtils.dart';
import '../../Utils/Network_Utils.dart';

class AddUpdateHotelDetailsPage extends StatefulWidget {
  final Restaurant? restaurant;

  const AddUpdateHotelDetailsPage({Key? key, this.restaurant}) : super(key: key);

  @override
  State<AddUpdateHotelDetailsPage> createState() => _AddUpdateHotelDetailsPageState();
}

class _AddUpdateHotelDetailsPageState extends State<AddUpdateHotelDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _loginBtnState = 0;

  LatLng? _initialLocation;
  String address = '';

  final TextEditingController hotelNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController openingHoursController = TextEditingController();
  final TextEditingController closingHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.restaurant != null) {
      hotelNameController.text = widget.restaurant!.name ?? '';
      addressController.text = widget.restaurant!.location.address ?? '';
      cityController.text = widget.restaurant!.location.city ?? '';
      stateController.text = widget.restaurant!.location.state ?? '';
      countryController.text = widget.restaurant!.location.country ?? '';
      zipCodeController.text = widget.restaurant!.location.zipcode ?? '';
      latitudeController.text = widget.restaurant!.location.coordinates[0].toString();
      longitudeController.text = widget.restaurant!.location.coordinates[1].toString();
      contactNumberController.text = widget.restaurant!.contactNumber ?? '';
      openingHoursController.text = widget.restaurant!.openingHours.open ?? '';
      closingHoursController.text = widget.restaurant!.openingHours.close ?? '';
    }
  }

  @override
  void dispose() {
    hotelNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    zipCodeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    contactNumberController.dispose();
    openingHoursController.dispose();
    closingHoursController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      await addOrUpdateHotelDetails();
    }
  }

  Future<void> addOrUpdateHotelDetails() async {
    setState(() {
      _loginBtnState = 1;
    });

    Map<String, String> data = {
      'hotelName': hotelNameController.text,
      'hotelLocationAddress': addressController.text,
      'hotelLocationCity': cityController.text,
      'hotelLocationState': stateController.text,
      'hotelLocationCountry': countryController.text,
      'hotelLocationZipCode': zipCodeController.text,
      'hotelLocationCoordinatesLat': latitudeController.text,
      'hotelLocationCoordinatesLng': longitudeController.text,
      'hotelContactNumber': contactNumberController.text,
      'openingHours': openingHoursController.text,
      'closingHours': closingHoursController.text,
    };

    try {
      final response = await NetworkUtil.post(
        NetworkUtil.HOTEL_DETAILS_ADD_URL,
        body: data,
      );

      setState(() {
        _loginBtnState = 0;
      });

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        AppUtil.showToast(context, result['message']);

        Navigator.pop(context, true);
      } else {
        AppUtil.showToast(context, "Something went wrong. Please try again.");
      }
    } catch (e) {
      setState(() {
        _loginBtnState = 0;
      });
      AppUtil.showToast(context, "Failed to connect to server.");
    }
  }

  Future<void> selectLocationFromMap() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MapPicker(Location: _initialLocation)),
    );

    if (result is LatLng) {
      _initialLocation = result;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _initialLocation!.latitude,
        _initialLocation!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        setState(() {
          addressController.text = place.locality ?? '';
          cityController.text = place.locality ?? '';
          stateController.text = place.administrativeArea ?? '';
          countryController.text = place.country ?? '';
          zipCodeController.text = place.postalCode ?? '';
          latitudeController.text = _initialLocation!.latitude.toString();
          longitudeController.text = _initialLocation!.longitude.toString();

          address =
          '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}';
        });

        debugPrint("Updated Address: $address");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.restaurant == null ? "Add Hotel Details" : "Edit Hotel Details"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Hotel Name", Icons.hotel, hotelNameController),
              buildTextField("Address", Icons.location_on_outlined, addressController),
              buildTextField("City", Icons.location_city, cityController),
              buildTextField("State", Icons.map_outlined, stateController),
              buildTextField("Country", Icons.flag_outlined, countryController),
              buildTextField("Zip Code", Icons.code_outlined, zipCodeController),
              buildTextField("Latitude", Icons.gps_fixed_outlined, latitudeController),
              buildTextField("Longitude", Icons.gps_fixed_outlined, longitudeController),
              buildTextField("Contact Number", Icons.phone_outlined, contactNumberController, isPhone: true),
              buildTextField("Opening Hours", Icons.access_time_outlined, openingHoursController),
              buildTextField("Closing Hours", Icons.access_time_outlined, closingHoursController),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: selectLocationFromMap,
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
                child: const Text("Select from Map", style: TextStyle(fontSize: 16, color: Colors.black)),
              ),

              Text(address),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginBtnState == 1 ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _loginBtnState == 1
                      ? const CircularProgressIndicator()
                      : Text(widget.restaurant == null ? "Submit" : "Update",
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, TextEditingController controller, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder()),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        validator: (value) => value!.isEmpty ? "$label is required" : null,
      ),
    );
  }
}
