import 'package:flutter/material.dart';
import 'package:contact_app/screens/splash.dart';
import 'package:contact_app/screens/signup.dart';
import 'package:contact_app/screens/login.dart';
import 'package:contact_app/screens/home.dart';
import 'package:contact_app/screens/profile.dart';
import 'package:contact_app/screens/forgotpassword.dart';
import 'package:contact_app/screens/verifycode.dart';
import 'package:contact_app/screens/profiledetails.dart';
import 'package:contact_app/screens/updatecontact.dart';
import 'package:contact_app/screens/createcontact.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Loading(),
      '/signup': (context) => SignUp(),
      '/login': (context) => Login(),
      '/home': (context) => Home(),
      '/profileupdate': (context) => ProfileEdit(),
      '/forgotpassword': (context) => ForgotPassword(),
      '/verifycode': (context) => VerifyCode(),
      '/profile': (context) => Profile(),
      '/contactupdate': (context) => ContactDetailsScreen(),
      '/create': (context) => ContactCreate(),
    },
    theme: ThemeData(
      fontFamily: 'OpenSans',
      primaryColor: Color(0xFF283149),
      colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF283149)),
    ),
  ));
}
