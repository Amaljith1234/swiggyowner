import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../../utils/Network_Utils.dart';

class GoogleMapSearchPlacesApi extends StatefulWidget {
  const GoogleMapSearchPlacesApi({Key? key}) : super(key: key);

  @override
  _GoogleMapSearchPlacesApiState createState() =>
      _GoogleMapSearchPlacesApiState();
}

class _GoogleMapSearchPlacesApiState extends State<GoogleMapSearchPlacesApi> {
  final _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];

  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _onChanged();
    });
    focusNode.requestFocus();
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  void getSuggestion(String input) async {
    if (input.isEmpty) return;
    PlacesAutocompleteResponse response =
        await GoogleMapsPlaces(apiKey: PLACES_API_KEY).autocomplete(
      input,
      components: [
        Component(Component.country, "IN")
      ], // Example: Restrict search to the United States
    );

    setState(() {
      _placeList = response.predictions!;
    });
  }

  void _selectPlace(int index) async {
    Prediction selectedPrediction = _placeList[index];
    PlacesDetailsResponse place = await GoogleMapsPlaces(
      apiKey: PLACES_API_KEY,
    ).getDetailsByPlaceId(selectedPrediction.placeId!);

    LatLng latLng = LatLng(place.result.geometry!.location.lat!,
        place.result.geometry!.location.lng!);
    Navigator.of(context).pop(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Location'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                style: GoogleFonts.poppins(
                  color: const Color(0xff020202),
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
                autofocus: true,
                focusNode: focusNode,
                controller: _controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  filled: true,
                  fillColor: const Color(0xffffffff),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Search for location",
                  hintStyle: GoogleFonts.poppins(
                      color: const Color(0xffb2b2b2),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      decorationThickness: 6),
                  prefixIcon: const Icon(Icons.search),
                  prefixIconColor: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _placeList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    _selectPlace(index);
                  },
                  child: ListTile(
                    title: Text(_placeList[index].description),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
