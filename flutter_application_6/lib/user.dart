import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const String url = 'assets/user.json';

Future<String> fetchData() async {
  try {
    String jsonString = await rootBundle.loadString('assets/user.json');
    debugPrint(jsonString);
    return jsonString;
  } catch (e) {
    throw Exception('Failed to load local JSON file: $e');
  }
}

Future<String> postData(Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      print("postData 201");
      return response.body;
    } else {
      throw Exception(
          'Failed to post data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to post data: $e');
  }
}

Future<String> putData(Map<String, dynamic> data) async {
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print("putData 200");
      return response.body;
    } else {
      throw Exception(
          'Failed to update data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to update data: $e');
  }
}

void deleteUser(List<User> users, int userId, Function updateUI) {
  users.removeWhere((user) => user.user_id == userId);
  updateUI();
}

void editUser(List<User> users, int userId, String newUsername,
    String newPassword, String newUuid, Function updateUI) {
  User user = users.firstWhere((user) => user.user_id == userId);
  user.username = newUsername;
  user.password = newPassword;
  user.uuid = newUuid;
  updateUI();
}

List<User> parseUsers(String jsonStr) {
  final List<dynamic> jsonData = json.decode(jsonStr);
  return jsonData.map((data) => User.fromJson(data)).toList();
}

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String data = '';
  List<User> users = [];

  void _loadData() async {
    try {
      String jsonData = await fetchData();
      setState(() {
        users = parseUsers(jsonData);
        data = jsonData;
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  void _addFakeUser() {
    final fakeUser = User(
      user_id: users.length + 1,
      username: 'New User ${users.length + 1}',
      password: 'password123',
      uuid: 'fake-uuid-${users.length + 1}',
    );
    setState(() {
      users.add(fakeUser);
    });
  }

  void _openEditModal(User user) {
    final TextEditingController usernameController =
        TextEditingController(text: user.username);
    final TextEditingController passwordController =
        TextEditingController(text: user.password);
    final TextEditingController uuidController =
        TextEditingController(text: user.uuid);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: uuidController,
                decoration: const InputDecoration(labelText: 'UUID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                editUser(
                  users,
                  user.user_id,
                  usernameController.text,
                  passwordController.text,
                  uuidController.text,
                  () {
                    setState(() {});
                  },
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (users.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user.user_id.toString()),
                      ),
                      title: Text(user.username),
                      subtitle: Text('UUID: ${user.uuid}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _openEditModal(user);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteUser(users, user.user_id, () {
                                setState(() {});
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (data.isNotEmpty && users.isEmpty)
            Text(
              data,
              style: const TextStyle(fontSize: 18),
            ),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('GET Data'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _addFakeUser();
            },
            child: const Text('Post Data'),
          ),
        ],
      ),
    );
  }
}

// Class สำหรับแปลง JSON
class User {
  final int user_id;
  String username;
  String password;
  String uuid;

  User({
    required this.user_id,
    required this.username,
    required this.password,
    required this.uuid,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      user_id: json['user_id'],
      username: json['username'],
      password: json['password'],
      uuid: json['uuid'],
    );
  }
}
