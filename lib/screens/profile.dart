import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:contact_app/theme/colours.dart';
import 'package:contact_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late String imagePath = '';
  late String image = '';
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  var file;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> updateUserDetails(User currentUser) async {
    String newName = _nameController.text;
    String newPhoneNumber = _phoneNumberController.text;
    String newEmail = _emailController.text;
    String base = '';
    if (file != null) {
      base = base64Encode(await file.readAsBytes());
    }
    try {
      Map<String, dynamic> requestBody = {};
      if (base == '') {
        requestBody = {
          'name': newName,
          'contact': newPhoneNumber,
          'email': newEmail
        };
      } else {
        requestBody = {
          'name': newName,
          'contact': newPhoneNumber,
          'email': newEmail,
          'image': base,
        };
      }
      var token = await storage.read(key: 'token');
      final response = await http.patch(
        Uri.parse('$api/userupdate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        Navigator.pushNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user details')),
        );
      }
    } catch (error) {
      print('Error updating user: $error');
    }
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  file = await _picker.pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    setState(() {
                      image = file.path;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  file = await _picker.pickImage(source: ImageSource.camera);
                  if (file != null) {
                    setState(() {
                      image = file.path;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User currentUser = ModalRoute.of(context)!.settings.arguments as User;
    _nameController.text = currentUser.name;
    _phoneNumberController.text = currentUser.phoneNumber;
    _emailController.text = currentUser.email;
    imagePath = currentUser.imageId;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      appBar: AppBar(
        title: Text('Profile Details'),
        backgroundColor: background,
      ),
      body: SafeArea(
          child: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [],
                  ),
                  GestureDetector(
                    onTap: () {
                      _changeProfilePicture();
                    },
                    child: CircleAvatar(
                      backgroundImage: image.isEmpty
                          ? NetworkImage(imagePath)
                          : FileImage(File(image)) as ImageProvider,
                      radius: 50.0,
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    width: 300.0,
                    child: TextFormField(
                      controller: _nameController,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        final RegExp nameRegExp = RegExp(r'^[a-zA-Z ]+$');
                        if (!nameRegExp.hasMatch(value.trim())) {
                          return 'Please enter a valid name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    width: 300.0,
                    child: TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.number,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        final RegExp phoneRegExp = RegExp(r'^[0-9]{10}$');
                        if (!phoneRegExp.hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    width: 300.0,
                    child: TextFormField(
                      controller: _emailController,
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
                        color: accent,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        final RegExp emailRegExp = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          caseSensitive: false,
                          multiLine: false,
                        );
                        if (!emailRegExp.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
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
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(primary),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          updateUserDetails(currentUser);
                        }
                      },
                      child: Text(
                        'Update',
                        style: TextStyle(
                          color: secondary,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                ]),
          ),
        ),
      )),
    );
  }
}
