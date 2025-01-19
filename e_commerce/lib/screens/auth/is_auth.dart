import 'package:flutter/material.dart';

import '../../services/locals/shared_pres_service.dart';
import '../main-scaffold/main_screen.dart';
import 'auth_screen.dart';

class IsAuth extends StatefulWidget {
  const IsAuth({super.key});

  @override
  State<IsAuth> createState() => _IsAuthState();
}

class _IsAuthState extends State<IsAuth> {
  bool _isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    authState();
  }

  Future<void> authState() async {
    final result = await SharedPresService.getToken();
    setState(() {
      if (result != null) {
        _isLoggedIn = !_isLoggedIn;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? MainScreen() : AuthScreen();
  }
}
