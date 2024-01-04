import 'package:flutter/material.dart';
import 'package:contact_app/theme/colours.dart';

class NoNet extends StatefulWidget {
  const NoNet({super.key});

  @override
  State<NoNet> createState() => _NoNetState();
}

class _NoNetState extends State<NoNet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contact_phone_rounded,
              size: 100.0,
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              textAlign: TextAlign.start,
              'No Internet\nTry later',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w400,
                color: secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
