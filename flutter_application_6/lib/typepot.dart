import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String url = 'http://192.168.81.223:5000/api/mushroom';

Future<String> fetchData() async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      debugPrint(response.body);
      return response.body;
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

Future<String> postData(Map<String, dynamic> data) async {
  try {
    // สำหรับตัวอย่างนี้ เราจำลองการ POST โดยไม่ส่งข้อมูลไปเซิร์ฟเวอร์จริง
    print("Post Data: $data");
    return Future.value(json.encode(data));
  } catch (e) {
    throw Exception('Failed to post data: $e');
  }
}

Future<String> putData(Map<String, dynamic> data) async {
  try {
    print("Put Data: $data");
    return Future.value(json.encode(data));
  } catch (e) {
    throw Exception('Failed to update data: $e');
  }
}

void deleteTypepot(List<Typepot> typepots, int typePotId, Function updateUI) {
  typepots.removeWhere((item) => item.type_pot_id == typePotId);
  updateUI();
}

void editTypepot(List<Typepot> typepots, int typePotId, String newName,
    String newDescription, int newStatus, Function updateUI) {
  Typepot item = typepots.firstWhere((item) => item.type_pot_id == typePotId);
  item.type_pot_name = newName;
  item.description = newDescription;
  item.status = newStatus;
  updateUI();
}

List<Typepot> parseTypepots(String jsonStr) {
  final decoded = json.decode(jsonStr);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    final List<dynamic> list = decoded['data'];
    return list.map((data) => Typepot.fromJson(data)).toList();
  } else {
    throw Exception("Unexpected JSON format");
  }
}

class TypepotPage extends StatefulWidget {
  const TypepotPage({super.key});

  @override
  State<TypepotPage> createState() => _TypepotPageState();
}

class _TypepotPageState extends State<TypepotPage> {
  String data = '';
  List<Typepot> typepots = [];

  void _loadData() async {
    try {
      String jsonData = await fetchData();
      setState(() {
        typepots = parseTypepots(jsonData);
        data = jsonData;
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  void _addFakeTypepot() {
    final fakeTypepot = Typepot(
      type_pot_id: typepots.isEmpty ? 111101 : typepots.last.type_pot_id + 1,
      type_pot_name: 'New Typepot ${typepots.length + 1}',
      description: 'Fake description ${typepots.length + 1}',
      status: 1,
    );
    setState(() {
      typepots.add(fakeTypepot);
    });
  }

  void _openEditModal(Typepot item) {
    final TextEditingController nameController =
        TextEditingController(text: item.type_pot_name);
    final TextEditingController descriptionController =
        TextEditingController(text: item.description);
    final TextEditingController statusController =
        TextEditingController(text: item.status.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Typepot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Typepot Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'Status'),
                keyboardType: TextInputType.number,
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
                editTypepot(
                  typepots,
                  item.type_pot_id,
                  nameController.text,
                  descriptionController.text,
                  int.tryParse(statusController.text) ?? 1,
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (typepots.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: typepots.length,
                  itemBuilder: (context, index) {
                    final item = typepots[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(item.type_pot_id.toString()),
                        ),
                        title: Text(item.type_pot_name),
                        subtitle: Text(
                            'Description: ${item.description}\nStatus: ${item.status}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _openEditModal(item);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteTypepot(typepots, item.type_pot_id, () {
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
            if (data.isNotEmpty && typepots.isEmpty)
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
              onPressed: _addFakeTypepot,
              child: const Text('Post Data'),
            ),
          ],
        ),
      ),
    );
  }
}

class Typepot {
  int type_pot_id;
  String type_pot_name;
  String description;
  int status;

  Typepot({
    required this.type_pot_id,
    required this.type_pot_name,
    required this.description,
    required this.status,
  });

  factory Typepot.fromJson(Map<String, dynamic> json) {
    return Typepot(
      type_pot_id: json['type_pot_id'],
      type_pot_name: json['type_pot_name'],
      description: json['description'],
      status:
          json['status'] is bool ? (json['status'] ? 1 : 0) : json['status'],
    );
  }
}
