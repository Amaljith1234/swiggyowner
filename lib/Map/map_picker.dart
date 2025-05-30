import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../Utils/Network_Utils.dart';
import '../Utils/AppUtils.dart';
import 'GoogleMapSearchPlacesApi.dart';

class MapPicker extends StatefulWidget {
  LatLng? Location;

  MapPicker({required this.Location});

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  LatLng? _initialLocation;
  GoogleMapController? _mapController;

  final List<Marker> _markers = [];

  String address = "";
  bool isSelected = false;
  String selectedLabel = "Home"; // Default selection

  Placemark? placemark;

  @override
  void initState() {
    _initialLocation = widget.Location;
    super.initState();
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      LatLng currentLocation = await AppUtil.getCurrentLocation();
      setState(() {
        _initialLocation = currentLocation;
      });
    } else {
      // Handle the case where the user denied location permissions
      AppUtil.errorAlert(context, "Need Location Permission");
    }
  }

  // Future<void> submit() async {
  //   if (placemark == null) {
  //     AppUtil.errorAlert(context, "Please select a location.");
  //     return;
  //   }
  //
  //   final String street = placemark!.subLocality.toString();
  //   final String city = placemark!.locality.toString();
  //   final String state = placemark!.administrativeArea.toString();
  //   final String country = placemark!.country.toString();
  //   final String zipCode = placemark!.postalCode.toString();
  //   final String lat = _initialLocation!.latitude.toString();
  //   final String lng = _initialLocation!.longitude.toString();
  //   final String primary = 'true';
  //
  //   Map<String, String> data = {
  //     'label': selectedLabel,
  //     'street': street,
  //     'city': city,
  //     'state': state,
  //     'country': country,
  //     'zipCode': zipCode,
  //     'lat': lat,
  //     'lng': lng,
  //     'primaryAddress' : primary
  //   };
  //
  //   try {
  //     final response = await NetworkUtil.post(
  //         NetworkUtil.ADD_UPDATE_ADDRESS_URL,
  //         body: data);
  //
  //     debugPrint("Response Body: ${response.body}");
  //     debugPrint("Status Code: ${response.statusCode}");
  //
  //     if (response.statusCode == 200) {
  //       var result = json.decode(response.body);
  //
  //       if (result['success'] == true) {
  //         AppUtil.showToast(context, "Address saved successfully!");
  //       } else {
  //         AppUtil.showToast(context, result['message']);
  //       }
  //     } else {
  //       AppUtil.showToast(context, "Failed to update address.");
  //     }
  //   } catch (e) {
  //     debugPrint("Error: $e");
  //     AppUtil.showToast(context, "An error occurred. Please try again.");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Set Location'),
      ),
      body: _initialLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialLocation!, // Initial map position
                    zoom: 15.0,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    final marker = Marker(
                        markerId: const MarkerId('0'),
                        position: _initialLocation!);
                    _markers.add(marker);
                  },
                  // myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  onCameraMove: (position) async {
                    placemark =
                        await AppUtil.getAddressFromLatLng(_initialLocation!);
                    _markers.first =
                        _markers.first.copyWith(positionParam: position.target);
                    _initialLocation = _markers.first.position;
                    setState(() {});
                  },
                  markers: _markers.toSet(),
                ),
                Positioned(
                  top: 10.0,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const GoogleMapSearchPlacesApi()));

                              LatLng? latLng = result as LatLng?;
                              if (latLng != null) {
                                _initialLocation = latLng;
                                _mapController!.animateCamera(
                                    CameraUpdate.newLatLng(latLng));

                                _markers.first = _markers.first
                                    .copyWith(positionParam: _initialLocation);

                                setState(() {});
                              }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              height: 56, // Adjust height as needed
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xffffffff),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(
                                        0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: Colors.black),
                                  const SizedBox(width: 16),
                                  Text(
                                    "Search for location",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xffb2b2b2),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16.0,
                  child: MaterialButton(
                    color: Colors.white,
                    onPressed: () async {
                      Position position = await getUserCurrentLocation();
                      _mapController!.animateCamera(CameraUpdate.newLatLng(
                          LatLng(position.latitude, position.longitude)));
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gps_fixed, color: Colors.black),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "LOCATE ME",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

      bottomNavigationBar: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.pin_drop),
                  Text(
                    placemark == null
                        ? "--"
                        : placemark!.subLocality.toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              placemark != null
                  ? Row(
                      children: [
                        Text(
                          "${placemark!.locality}, ",
                        ),
                        Text(
                          "${placemark!.administrativeArea}, ",
                        ),
                        Text(
                          placemark!.postalCode.toString(),
                        ),
                        Text(', ${placemark!.country.toString()}'),
                      ],
                    )
                  : SizedBox(),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      height: 40,
                      onPressed: () {
                        // submit();
                        Navigator.of(context).pop(_initialLocation);
                      },
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text(
                        "CONFIRM LOCATION",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Navigator.pop(context, 'Value from Second Page');
    );
  }

  List<String> reportList = [
    "Home",
    "Work",
    "Shop",
  ];

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }
}
