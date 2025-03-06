import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String url = 'http://192.168.1.120:5000/api/mushroom';

// ฟังก์ชันโหลดข้อมูล JSON
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
    throw Exception('Failed to load data in fetchData: $e');
  }
}

// ฟังก์ชันสำหรับ POST ข้อมูล (จำลองการเพิ่มข้อมูล)
Future<void> postTypepotData(Typepot newTypepot, Function _loadData) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newTypepot.toJson()),
    );
    if (response.statusCode == 201) {
      _loadData();
    } else {
      throw Exception(
          'Failed to post data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to post data: $e');
  }
}

// ฟังก์ชันสำหรับ PUT ข้อมูล (จำลองการแก้ไขข้อมูล)
Future<void> putTypepotData(Typepot updatedTypepot, Function _loadData) async {
  try {
    final response = await http.put(
      Uri.parse('$url/${updatedTypepot.type_pot_id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedTypepot.toJson()),
    );
    if (response.statusCode == 200) {
      _loadData();
    } else {
      throw Exception(
          'Failed to update data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to update data: $e');
  }
}

Future<void> deleteTypepotData(int typePotId, Function _loadData) async {
  try {
    final response = await http.delete(
      Uri.parse('$url/$typePotId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      _loadData();
    } else {
      throw Exception(
          'Failed to delete data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to delete data: $e');
  }
}

// ฟังก์ชันสำหรับ DELETE ข้อมูล (ลบข้อมูลจาก UI)
void deleteTypepot(List<Typepot> typepots, int typePotId, Function updateUI,
    Function _loadData) async {
  try {
    await deleteTypepotData(typePotId, _loadData);
    typepots.removeWhere((item) => item.type_pot_id == typePotId);
    updateUI();
  } catch (e) {
    throw Exception('Failed to delete typepot: $e');
  }
}

// ฟังก์ชันสำหรับแก้ไขข้อมูล Typepot
void editTypepot(List<Typepot> typepots, int typePotId, String newName,
    String newDescription, int newStatus, Function updateUI) {
  Typepot item = typepots.firstWhere((item) => item.type_pot_id == typePotId);
  item.type_pot_name = newName;
  item.description = newDescription;
  item.status = newStatus;
  updateUI();
}

// แปลง JSON เป็น List<Typepot>
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
  @override
  void initState() {
    super.initState();
    _loadData(); // Call _loadData when the page is initialized
  }

  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<Typepot> typepots = []; // สำหรับเก็บ List ของ Typepot

  void _loadData() async {
    try {
      String jsonData = await fetchData();
      setState(() {
        typepots = parseTypepots(jsonData); // แปลง JSON เป็น Typepot List
        data = jsonData;
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  // ฟังก์ชันเปิด modal แก้ไขข้อมูล Typepot
  void _openEditModal(Typepot item) {
    final TextEditingController nameController =
        TextEditingController(text: item.type_pot_name);
    final TextEditingController descriptionController =
        TextEditingController(text: item.description);
    String selectedStatus = item.status == 1 ? 'Active' : 'Inactive';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Typepot'),
          content: SingleChildScrollView(
            child: Column(
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
                DropdownButtonFormField<String>(
                  value: selectedStatus.isEmpty ? null : selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value ?? '';
                    });
                  },
                  hint: const Text('Select Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedTypepot = Typepot(
                  type_pot_id: item.type_pot_id,
                  type_pot_name: nameController.text,
                  description: descriptionController.text,
                  status: selectedStatus == 'Active' ? 1 : 0,
                );
                await putTypepotData(updatedTypepot, _loadData);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _openAddModal() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedStatus = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Typepot'),
          content: SingleChildScrollView(
            child: Column(
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
                DropdownButtonFormField<String>(
                  value: selectedStatus.isEmpty ? null : selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value ?? '';
                    });
                  },
                  hint: const Text('Select Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newTypepot = Typepot(
                  type_pot_id:
                      typepots.isNotEmpty ? typepots.last.type_pot_id + 1 : 1,
                  type_pot_name: nameController.text,
                  description: descriptionController.text,
                  status: selectedStatus == 'Active' ? 1 : 0,
                );
                await postTypepotData(newTypepot, _loadData);
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
            // แสดง ListView ถ้ามีข้อมูล
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
                            'Description: ${item.description}\nStatus: ${item.status == 1 ? 'Active' : 'Inactive'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ปุ่ม Edit
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _openEditModal(item);
                              },
                            ),
                            // ปุ่ม Delete
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteTypepot(typepots, item.type_pot_id, () {
                                  setState(() {});
                                }, _loadData);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            // แสดงข้อความเมื่อไม่มีข้อมูล
            if (data.isNotEmpty && typepots.isEmpty)
              Text(
                data,
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openAddModal,
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
      status: json['status'] == true ? 1 : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_pot_id': type_pot_id,
      'type_pot_name': type_pot_name,
      'description': description,
      'status': status == 1,
    };
  }
}
