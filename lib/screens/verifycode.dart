import 'package:flutter/material.dart';
import 'package:contact_app/theme/colours.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyCode extends StatefulWidget {
  const VerifyCode({Key? key});

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  late List<TextEditingController> _controllers;
  late TextEditingController _passwordController;
  late List<String> arg;
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _passwordController = TextEditingController();
    _configureTextFields();
  }

  void _configureTextFields() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < _controllers.length - 1) {
          FocusScope.of(context).nextFocus();
        }
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
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

  String getOtpFromFields() {
    String otp = '';
    for (TextEditingController controller in _controllers) {
      otp += controller.text;
    }
    return otp;
  }

  Future<void> reset() async {
    try {
      final Map<String, dynamic> requestBody = {
        'password': _passwordController.text,
        'encrypt': arg[0],
        'email': arg[1],
        'otp': getOtpFromFields()
      };
      final response = await http.post(
        Uri.parse('$api/reset'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      if (response.statusCode == 400) {
        final dynamic responseData = json.decode(response.body);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Password Reset Fail',
                  style: TextStyle(color: secondary)),
              content: Text(responseData['error']),
              backgroundColor: background,
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                        color: secondary, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () async {
                    Navigator.pushReplacementNamed(
                      context,
                      '/forgotpassword',
                    );
                  },
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 200) {
        Navigator.pushNamed(
          context,
          '/login',
        );
      }
    } catch (error) {
      print('Error resetting password: $error');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    arg = ModalRoute.of(context)!.settings.arguments as List<String>;
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            )),
            padding: EdgeInsets.all(16.0),
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
                  'Verification Code',
                  style: TextStyle(
                      color: secondary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  'Enter the verification code sent to your email',
                  style: TextStyle(
                      color: accent,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildOtpFields(),
                ),
                SizedBox(
                  height: 30.0,
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
                  height: 30.0,
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
                        reset();
                      }
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: secondary,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOtpFields() {
    List<Widget> fields = [];
    for (int i = 0; i < _controllers.length; i++) {
      fields.add(
        SizedBox(
          width: 40.0,
          child: TextFormField(
            controller: _controllers[i],
            maxLength: 1,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primary, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18.0, fontWeight: FontWeight.w600, color: secondary),
          ),
        ),
      );
      if (i < _controllers.length - 1) {
        fields.add(SizedBox(width: 20.0));
      }
    }
    return fields;
  }
}
