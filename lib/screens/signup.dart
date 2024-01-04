import 'package:flutter/material.dart';
import 'package:contact_app/theme/colours.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  const SignUp({Key? key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  String? _signupErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  String? _validateUsername(String? value) {
    if (value!.isEmpty) {
      return 'Please enter your name';
    }
    final RegExp usernameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!usernameRegExp.hasMatch(value.trim())) {
      return 'Invalid username';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value!.isEmpty) {
      return 'Please enter your phone number';
    }
    final RegExp phoneRegExp = RegExp(r'^[0-9]{10}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value!.isEmpty) {
      return 'Please enter your email';
    }
    final RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value!.isEmpty) {
      return 'Please enter your password';
    }
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    if (!passwordRegExp.hasMatch(value)) {
      return 'Password must be at least 8 characters long and contain a letter and a number';
    }
    return null;
  }

  void _updateSignupErrorMessage(String message) {
    setState(() {
      _signupErrorMessage = message;
    });
  }

  Future<void> sendSignupDataToNode({
    required String username,
    required String email,
    required String contact,
    required String password,
  }) async {
    final String apiUrl = '$api/signup';
    try {
      final Map<String, dynamic> requestBody = {
        'name': username,
        'email': email,
        'contact': contact,
        'password': password,
      };
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        _updateSignupErrorMessage('User signed up successfully');
        Navigator.pushNamed(
          context,
          '/login',
        );
      } else if (response.statusCode == 400) {
        final dynamic responseData = json.decode(response.body);
        if (responseData != null && responseData['error'] != null) {
          _updateSignupErrorMessage(responseData['error']);
        } else {
          _updateSignupErrorMessage('Failed to sign up user');
        }
      } else {
        _updateSignupErrorMessage('Failed to sign up user');
      }
    } catch (error) {
      _updateSignupErrorMessage('Error signing up user: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          )),
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.contact_phone_rounded,
                  color: primary,
                  size: 100.0,
                ),
                Text(
                  'Sign Up to get started',
                  style: TextStyle(
                      color: secondary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 30.0,
                ),
                SizedBox(
                  width: 300.0,
                  child: TextFormField(
                    controller: _usernameController,
                    validator: _validateUsername,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      hintText: 'Name',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primary, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: accent),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  width: 300.0,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    validator: _validatePhone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      hintText: 'Phone',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primary, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: accent),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  width: 300.0,
                  child: TextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      hintText: 'Email',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primary, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: accent),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  width: 300.0,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: _validatePassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      hintText: 'Password',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primary, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: accent,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: accent),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  width: 300.0,
                  height: 60.0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(primary),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        sendSignupDataToNode(
                          username: _usernameController.text,
                          contact: _phoneController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                      }
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: secondary,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _signupErrorMessage!.isNotEmpty,
                  child: Text(
                    _signupErrorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?\t',
                      style: TextStyle(
                          color: accent,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/login',
                        );
                      },
                      child: Text(
                        'LOGIN',
                        style: TextStyle(
                          color: secondary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: secondary,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
