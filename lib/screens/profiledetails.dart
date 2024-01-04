import 'package:flutter/material.dart';
import 'package:contact_app/theme/colours.dart';
import 'package:http/http.dart' as http;
import 'package:contact_app/models/user.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late User currentUser =
      User(id: '', name: '', email: '', phoneNumber: '', imageId: '');
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> saveToLocal(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(data));
  }

  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    if (userData != null) {
      setState(() {
        currentUser = User.fromJson(jsonDecode(userData));
      });
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
        saveToLocal(newUser.toJson());
        setState(() {
          currentUser = newUser;
        });
      } else {
        await loadFromLocal();
      }
    } catch (error) {
      await loadFromLocal();
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete', style: TextStyle(color: secondary)),
          content: Text('Are you sure you want to delete your account?'),
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
                print('in delete');
                var token = await storage.read(key: 'token');
                final response = await http.delete(
                  Uri.parse('$api/deleteuser'),
                  headers: {
                    'Authorization': '$token',
                  },
                );
                if (response.statusCode == 200) {
                  Navigator.pushReplacementNamed(context, '/signup');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout', style: TextStyle(color: secondary)),
          content: Text('Are you sure you want to log out?'),
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
              child: Text('Logout',
                  style:
                      TextStyle(color: secondary, fontWeight: FontWeight.w700)),
              onPressed: () async {
                try {
                  await storage.delete(key: 'token');
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (error) {
                  print('Error logging out: $error');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = currentUser.imageId;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      appBar: AppBar(
        title: Text('Profile Details'),
        backgroundColor: background,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 20.0),
                CircleAvatar(
                  backgroundColor: imagePath.isNotEmpty ? null : secondary,
                  backgroundImage:
                      imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
                  radius: 80.0,
                  child: imagePath.isEmpty
                      ? Text(
                          currentUser.name.isNotEmpty
                              ? currentUser.name[0]
                              : '',
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 40.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        textAlign: TextAlign.start,
                        currentUser.name,
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w400,
                          color: secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text(
                        textAlign: TextAlign.start,
                        currentUser.phoneNumber,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          color: secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        textAlign: TextAlign.start,
                        currentUser.email,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          color: secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: 360.0,
              height: 60.0,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(background),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: accent,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/profileupdate',
                    arguments: currentUser,
                  );
                },
                child: Text(
                  'Update Profile',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            SizedBox(
              width: 360.0,
              height: 60.0,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(background),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: accent,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  _confirmDelete();
                },
                child: Text(
                  'Delete Profile',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            SizedBox(
              width: 360.0,
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
                  _logout();
                },
                child: Text(
                  'Logout',
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
    );
  }
}
