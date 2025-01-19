import 'package:e_commerce/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  final _txtFullName = TextEditingController();
  final _fullNameFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  LatLng? myCurrentLocation;
  String? _address;
  String? _subLocality;
  LatLng? _markerLocation;
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _txtFullName.dispose();
    _fullNameFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      myCurrentLocation = LatLng(position.latitude, position.longitude);
      _markerLocation = myCurrentLocation;
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: myCurrentLocation!,
      ));
    });

    _getAddressFromCoordinates(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks.first;

      setState(() {
        _subLocality = place.subLocality;
        _address =
        '''${place.street} ${place.subLocality} ${place.locality} ${place.country}
      ''';
      });
    } catch (e) {
      setState(() {
        _address = 'Failed to fetch address';
      });
    }
  }

  void _onCameraIdle() {
    _mapController?.getLatLng(
      ScreenCoordinate(
        x: MediaQuery.of(context).size.width ~/ 2,
        y: MediaQuery.of(context).size.height ~/ 2,
      ),
    ).then((latLng) {
      setState(() {
        _markerLocation = latLng;
        _getAddressFromCoordinates(latLng.latitude, latLng.longitude);
      });
    });
  }

  void _validateAndFocus() {
    bool isValid = _formKey.currentState!.validate();
    if (!isValid) {
      if (_txtFullName.text.isEmpty) {
        FocusScope.of(context).requestFocus(_fullNameFocusNode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F6FB),
      appBar: AppBar(
        title: Text("Shipping Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: myCurrentLocation == null
                      ? Center(child: CircularProgressIndicator())
                      : Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: myCurrentLocation ?? LatLng(0, 0),
                          zoom: 15,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onCameraIdle: _onCameraIdle,
                        markers: _markers,
                      ),
                      Center(
                        child: Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _subLocality ?? "Fetching sub-locality...",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _address ?? "Fetching address...",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(_fullNameFocusNode);
                  },
                  child: Text(
                    "Full Name",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller: _txtFullName,
                  focusNode: _fullNameFocusNode,
                  hint: 'Full Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Color(0xffDC1F26),
                  ),
                  onPressed: _validateAndFocus,
                  child: Text(
                    "Continue to Payment",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
