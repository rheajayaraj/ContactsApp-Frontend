import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:contact_app/theme/colours.dart';
import 'package:contact_app/services/option.dart';
import 'package:contact_app/models/contacts.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ContactDetailsScreen extends StatefulWidget {
  @override
  _ContactDetailsScreenState createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late String imagePath = '';
  late String image = '';
  final _formKey = GlobalKey<FormState>();
  List<String> userOptions = [];
  final storage = const FlutterSecureStorage();
  var file;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _addOption(String option) {
    setState(() {
      if (!userOptions.contains(option)) {
        userOptions.add(option);
      }
    });
  }

  Future<void> updateContactDetails(Contact currentContact) async {
    String newName = _nameController.text;
    String newPhoneNumber = _phoneNumberController.text;
    List<String> updatedTags = List.from(currentContact.tags as Iterable);
    updatedTags.addAll(userOptions);
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
          'tags': updatedTags,
        };
      } else {
        requestBody = {
          'name': newName,
          'contact': newPhoneNumber,
          'image': base,
          'tags': updatedTags,
        };
      }
      var token = await storage.read(key: 'token');
      String con = currentContact.id;
      final response = await http.post(
        Uri.parse('$api/update/$con'),
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
          SnackBar(content: Text('Failed to update contact details')),
        );
      }
    } catch (error) {
      print('Error creating contact: $error');
    }
  }

  void _pickContactPicture() async {
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
    final Contact currentContact =
        ModalRoute.of(context)!.settings.arguments as Contact;
    _nameController.text = currentContact.name;
    _phoneNumberController.text = currentContact.phoneNumber;
    imagePath = currentContact.imagePath!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      appBar: AppBar(
        title: Text('Contact Details'),
        backgroundColor: background,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickContactPicture,
                child: CircleAvatar(
                  backgroundImage: image.isEmpty
                      ? NetworkImage(imagePath)
                      : FileImage(File(image)) as ImageProvider,
                  radius: 50.0,
                ),
              ),
              SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
              Column(
                children: [
                  OptionEntryWidget(
                    onOptionAdded: _addOption,
                  ),
                  Column(
                    children: userOptions.map((option) {
                      return ListTile(
                        subtitle: Text(option),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
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
                      updateContactDetails(currentContact);
                    }
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
