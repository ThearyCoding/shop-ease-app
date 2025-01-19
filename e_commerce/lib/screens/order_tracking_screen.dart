import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final riderLocationProvider =
    StateNotifierProvider<RiderLocationNotifier, LatLng>((ref) {
  return RiderLocationNotifier();
});

final polylineProvider =
    StateNotifierProvider<PolylineNotifier, Polyline>((ref) {
  return PolylineNotifier();
});

class RiderLocationNotifier extends StateNotifier<LatLng> {
  RiderLocationNotifier()
      : super(LatLng(11.575278, 104.897222)); // Initial location

  void updateLocation(LatLng newLocation) {
    state = newLocation;
  }
}

class PolylineNotifier extends StateNotifier<Polyline> {
  PolylineNotifier()
      : super(Polyline(
          polylineId: PolylineId('route'),
          points: [],
          color: Colors.blue,
          width: 5,
        ));

  Future<void> updateRoute(LatLng origin, LatLng destination) async {
    String url =
        'http://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          if (geometry != null) {
            final points = PolylinePoints().decodePolyline(geometry);
            state = Polyline(
              polylineId: PolylineId('route'),
              points: points
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList(),
              color: Colors.blue,
              width: 5,
            );
          }
        }
      }
    } catch (e) {
      log('Error fetching directions: $e');
    }
  }
}

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  // ignore: library_private_types_in_public_api
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  GoogleMapController? _mapController;
  late WebSocketChannel channel;
  final Location _location = Location();

  final LatLng _destinationLocation = LatLng(11.545840, 104.929345);

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    _startLocationUpdates();
  }

  void _initializeWebSocket() {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://172.20.10.2:8080'),
      );

      channel.sink.add(json.encode({
        'type': 'identify',
        'role': 'user',
      }));

      channel.stream.listen((message) {
        final data = json.decode(message);
        if (data['type'] == 'locationUpdate') {
          final riderLocation = LatLng(data['latitude'], data['longitude']);
          ref
              .read(riderLocationProvider.notifier)
              .updateLocation(riderLocation);
          ref
              .read(polylineProvider.notifier)
              .updateRoute(riderLocation, _destinationLocation);
        }
      }, onError: (error) {
        log("WebSocket error: $error");
      }, onDone: () {
        log("WebSocket connection closed");
      });
    } catch (e) {
      log("Error connecting to WebSocket: $e");
    }
  }

  void _startLocationUpdates() async {
    // Ensure location services are enabled
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    // Request location permissions
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get the initial location and update route
    try {
      final initialLocation = await _location.getLocation();
      if (initialLocation.latitude != null &&
          initialLocation.longitude != null) {
        final currentLocation =
            LatLng(initialLocation.latitude!, initialLocation.longitude!);

        ref
            .read(riderLocationProvider.notifier)
            .updateLocation(currentLocation);

        // Fetch the route from the current location to the destination
        ref
            .read(polylineProvider.notifier)
            .updateRoute(currentLocation, _destinationLocation);

        // Send initial location to the server via WebSocket
        channel.sink.add(json.encode({
          'type': 'locationUpdate',
          'orderId': widget.orderId,
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
        }));
      }
    } catch (e) {
      log("Error getting initial location: $e");
    }

    // Start listening for location updates
    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        final newLocation =
            LatLng(locationData.latitude!, locationData.longitude!);

        // Update the rider's current location in state
        ref.read(riderLocationProvider.notifier).updateLocation(newLocation);

        // Update the route polyline (optional for dynamic recalculations)
        ref
            .read(polylineProvider.notifier)
            .updateRoute(newLocation, _destinationLocation);

        // Send location updates to the WebSocket server
        channel.sink.add(json.encode({
          'type': 'locationUpdate',
          'orderId': widget.orderId,
          'latitude': newLocation.latitude,
          'longitude': newLocation.longitude,
        }));
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riderLocation = ref.watch(riderLocationProvider);
    final polyline = ref.watch(polylineProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Tracking'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: riderLocation,
          zoom: 14.0,
        ),
        markers: {
          Marker(markerId: MarkerId('rider'), position: riderLocation),
        },
        polylines: {polyline},
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
