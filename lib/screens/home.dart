import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:contact_app/models/contacts.dart';
import 'package:contact_app/theme/colours.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:contact_app/screens/contact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contact_app/models/user.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Contact> contacts = [];
  late TextEditingController _searchController;
  final storage = const FlutterSecureStorage();
  late User currentUser =
      User(id: '', name: '', email: '', phoneNumber: '', imageId: '');

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    loadContactsFromLocal();
    fetchContacts();
    fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> saveContactsToLocal(List<dynamic> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('contacts', jsonEncode(contacts));
  }

  Future<void> loadContactsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getString('contacts');
    if (contactsJson != null) {
      final List<dynamic> savedContacts = jsonDecode(contactsJson);
      setState(() {
        contacts = savedContacts.map((contactData) {
          return Contact.fromJson(contactData);
        }).toList();
      });
    }
  }

  Future<void> fetchContacts() async {
    final apiUrl = '$api/viewAll';
    try {
      var token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': '$token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> fetchedContacts = json.decode(response.body);
        setState(() {
          contacts = fetchedContacts.map((contactData) {
            return Contact.fromJson(contactData);
          }).toList();
        });
        saveContactsToLocal(fetchedContacts);
      }
    } catch (error) {
      await loadContactsFromLocal();
    }
  }

  Future<void> fetchData() async {
    try {
      var token = await storage.read(key: 'token');
      final response = await http.post(
        Uri.parse('$api/user'),
        headers: {
          'Authorization': '$token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        final newUser = User.fromJson(userData['user']);
        setState(() {
          currentUser = newUser;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  List<Contact> getFilteredContacts(String query) {
    return contacts.where((contact) {
      final name = contact.name.toLowerCase();
      final phoneNumber = contact.phoneNumber.toLowerCase();
      final lowercaseQuery = query.toLowerCase();
      return name.contains(lowercaseQuery) ||
          phoneNumber.contains(lowercaseQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = currentUser.imageId;
    final filteredContacts = getFilteredContacts(_searchController.text);
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 5.0),
              Row(
                children: [
                  SizedBox(
                    width: 290.0,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        hintText: 'Search all contacts',
                        prefixIcon: Icon(Icons.search),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primary, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: accent),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/profile',
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: imagePath.isNotEmpty ? null : secondary,
                      backgroundImage:
                          imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
                      radius: 35.0,
                      child: imagePath.isEmpty
                          ? Text(
                              currentUser.name.isNotEmpty
                                  ? currentUser.name[0]
                                  : '',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: filteredContacts.isEmpty
                    ? Center(
                        child: Text(
                          'No contacts found',
                          style: TextStyle(fontSize: 16.0, color: secondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              filteredContacts[index].name,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: secondary,
                              ),
                            ),
                            subtitle: Text(
                              filteredContacts[index].phoneNumber,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: secondary,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContactScreen(
                                    contact: filteredContacts[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: primary,
        onPressed: () async {
          Navigator.pushNamed(
            context,
            '/create',
          );
        },
      ),
    );
  }
}
