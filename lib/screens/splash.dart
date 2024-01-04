import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:contact_app/theme/colours.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  final storage = const FlutterSecureStorage();

  void checkJWT() async {
    String? jwt = await storage.read(key: 'token');
    if (jwt != null) {
      Navigator.pushNamed(
        context,
        '/home',
      );
    } else {
      Navigator.pushNamed(
        context,
        '/login',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkJWT();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contact_phone_rounded,
              color: background,
              size: 100.0,
            ),
            SizedBox(
              height: 30.0,
            ),
            SpinKitWaveSpinner(
              color: background,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}
