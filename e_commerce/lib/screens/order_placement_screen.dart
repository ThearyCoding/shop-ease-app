import 'dart:developer';

import 'package:e_commerce/screens/order_tracking_screen.dart';
import 'package:e_commerce/services/locals/shared_pres_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';

class OrderPlacementScreen extends StatefulWidget {
  const OrderPlacementScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrderPlacementScreenState createState() => _OrderPlacementScreenState();
}

class _OrderPlacementScreenState extends State<OrderPlacementScreen> {
  String productId1 = "677f8d8e000711c8effd2768";
  String productId2 = "677d3876794a4a391d0199a6";
  LatLng currentLocation = LatLng(11.5675, 104.8885);

  Future<void> _placeOrder() async {
    final token = await SharedPresService.getToken();
    final userId = JwtDecoder.decode(token!)['id'];
    final response = await http.post(
      Uri.parse('http://172.20.10.2:3000/api/orders/place-order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'userId': userId,
        'items': [
          {'product': productId1, 'quantity': 2, 'price': 20},
          {'product': productId2, 'quantity': 1, 'price': 15},
        ],
        'shippingAddress': {
          'street': '123 Main St',
          'city': 'Your City',
          'country': 'Your Country',
          'postalCode': '12345',
        },
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final orderId = data['orderId'];
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(orderId: orderId),
        ),
      );
    } else {
      log('Failed to place order: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Place Order')),
      body: Center(
        child: ElevatedButton(
          onPressed: _placeOrder,
          child: Text('Place Order'),
        ),
      ),
    );
  }
}
