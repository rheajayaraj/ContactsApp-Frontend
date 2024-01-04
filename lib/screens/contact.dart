import 'package:flutter/material.dart';
import 'package:contact_app/models/contacts.dart';
import 'package:contact_app/theme/colours.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:share/share.dart';

// ignore: must_be_immutable
class ContactScreen extends StatefulWidget {
  final Contact contact;
  ContactScreen({required this.contact});

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late Contact currentContact = Contact(
    name: '',
    id: '',
    phoneNumber: '',
    email: '',
  );
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  String imagePath = '';
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  void shareContact() {
    String message =
        'Name: ${widget.contact.name}\nPhone: ${widget.contact.phoneNumber}';
    Share.share(message);
  }

  Future<void> getContactDetails() async {
    try {
      var token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse('$api/view/${widget.contact.id}'),
        headers: {
          'Authorization': '$token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> contactData = json.decode(response.body);
        setState(() {
          currentContact = Contact.fromJson(contactData);
        });
      } else {
        print('Failed to fetch contact details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching contact details: $error');
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete', style: TextStyle(color: secondary)),
          content:
              Text('Are you sure you want to delete ${widget.contact.name}?'),
          backgroundColor: background,
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: accent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete',
                  style:
                      TextStyle(color: secondary, fontWeight: FontWeight.w700)),
              onPressed: () async {
                deleteContact();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteContact() async {
    try {
      var token = await storage.read(key: 'token');
      final response = await http.delete(
        Uri.parse('$api/delete/${widget.contact.id}'),
        headers: {
          'Authorization': '$token',
        },
      );
      if (response.statusCode == 200) {
        Navigator.pushNamed(
          context,
          '/home',
        );
      } else {
        print('Failed to delete contact details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting contact: $error');
    }
  }

  void _makePhoneCall() async {
    try {
      final telScheme = Uri.parse('tel:${widget.contact.phoneNumber}');
      if (await canLaunchUrl(telScheme)) {
        await launchUrl(telScheme);
      } else {
        throw 'Could not launch $telScheme';
      }
    } catch (e) {
      print('Error launching phone call: $e');
    }
  }

  void _sendMessage() async {
    final telScheme = Uri.parse('sms:${widget.contact.phoneNumber}');
    if (await canLaunchUrl(telScheme)) {
      await launchUrl(telScheme);
    } else {
      throw 'Could not launch $telScheme';
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _phoneNumberController =
        TextEditingController(text: widget.contact.phoneNumber);
    imagePath = widget.contact.imagePath!;
    getContactDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(
                height: 400.0,
                width: 300.0,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(height: 10.0),
                          SizedBox(
                            width: 90.0,
                            height: 25.0,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll<Color>(
                                        background.withOpacity(0.8)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pushNamed(
                                  context,
                                  '/contactupdate',
                                  arguments: widget.contact,
                                );
                              },
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0)
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor:
                            imagePath.isNotEmpty ? null : secondary,
                        backgroundImage: imagePath.isNotEmpty
                            ? NetworkImage(imagePath)
                            : null,
                        radius: 80.0,
                        child: imagePath.isEmpty
                            ? Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text[0]
                                    : '',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      SizedBox(
                        width: 300.0,
                        child: Text(
                          textAlign: TextAlign.center,
                          _nameController.text,
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w400,
                            color: secondary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300.0,
                        child: Text(
                          textAlign: TextAlign.center,
                          _phoneNumberController.text,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                            color: secondary,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: secondary,
                            onPressed: () {
                              _confirmDelete();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.share),
                            color: secondary,
                            onPressed: () {
                              shareContact();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.message),
                            color: secondary,
                            onPressed: () {
                              _sendMessage();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.phone),
                            color: secondary,
                            onPressed: () {
                              _makePhoneCall();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Tags: ${widget.contact.tags!.join(', ')}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: secondary,
                        ),
                      ),
                    ],
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
