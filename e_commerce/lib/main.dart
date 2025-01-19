import '../../screens/order_placement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'core/constant.dart';
import 'screens/auth/is_auth.dart';
import 'screens/introduction/on_boarding_page.dart';
import 'services/locals/onboarding_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final NetworkInfo networkInfo = NetworkInfo();
  final String? ipv4 = await networkInfo.getWifiGatewayIP();
  if (ipv4 != null) {
    ConstantApp.baseUrl = "http://$ipv4:3000";
  } else {
    ConstantApp.baseUrl = "http://192.168.240.197:3000";
  }

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool onboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    onboardingComplete =
        await OnBoardServiceSharedPrefs.hasCompletedOnboarding();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
  //    home: onboardingComplete ? OnBoardingPage() : IsAuth(),
     home: OrderPlacementScreen(),
    );
  }
}
