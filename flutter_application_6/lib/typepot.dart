import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const String url = 'assets/typepot.json';

// ฟังก์ชันโหลดข้อมูล JSON
Future<String> fetchData() async {
  try {
    String jsonString = await rootBundle.loadString(url);
    debugPrint(jsonString);
    return jsonString;
  } catch (e) {
    throw Exception('Failed to load local JSON file: $e');
  }
}

// ฟังก์ชันสำหรับ POST ข้อมูล (จำลองการเพิ่มข้อมูล)
Future<String> postData(Map<String, dynamic> data) async {
  try {
    // สำหรับตัวอย่างนี้ เราจำลองการ POST โดยไม่ส่งข้อมูลไปเซิร์ฟเวอร์จริง
    print("Post Data: $data");
    return Future.value(json.encode(data));
  } catch (e) {
    throw Exception('Failed to post data: $e');
  }
}

// ฟังก์ชันสำหรับ PUT ข้อมูล (จำลองการแก้ไขข้อมูล)
Future<String> putData(Map<String, dynamic> data) async {
  try {
    print("Put Data: $data");
    return Future.value(json.encode(data));
  } catch (e) {
    throw Exception('Failed to update data: $e');
  }
}

// ฟังก์ชันสำหรับ DELETE ข้อมูล (ลบข้อมูลจาก UI)
void deleteTypepot(List<Typepot> typepots, int typePotId, Function updateUI) {
  typepots.removeWhere((item) => item.type_pot_id == typePotId);
  updateUI();
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
  final List<dynamic> jsonData = json.decode(jsonStr);
  return jsonData.map((data) => Typepot.fromJson(data)).toList();
}

class TypepotPage extends StatefulWidget {
  const TypepotPage({super.key});

  @override
  State<TypepotPage> createState() => _TypepotPageState();
}

class _TypepotPageState extends State<TypepotPage> {
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

  // ฟังก์ชันเพิ่มข้อมูลหลอก (Post Data)
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

  // ฟังก์ชันเปิด modal แก้ไขข้อมูล Typepot
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
                            'Description: ${item.description}\nStatus: ${item.status}'),
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
            // แสดงข้อความเมื่อไม่มีข้อมูล
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
      status: json['status'],
    );
  }
}
