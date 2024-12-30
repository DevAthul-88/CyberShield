import 'package:cybershield/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VulnerabilityScanner());
}

class VulnerabilityScanner extends StatelessWidget {
  const VulnerabilityScanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FToastBuilder(),
      title: "CyberShield",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            primary: Colors.deepOrange,
            brightness: Brightness.dark),
        useMaterial3: true,
        primaryColor: Colors.deepOrange, // Set the primary color to orange
        primarySwatch: Colors.deepOrange, // Use the orange color swatch
        brightness: Brightness.dark, // Keep the dark theme
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
