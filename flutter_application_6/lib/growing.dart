import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const String url = 'assets/growing.json';

// ฟังก์ชันโหลดข้อมูล JSON
Future<String> fetchData() async {
  try {
    String jsonString = await rootBundle.loadString('assets/growing.json');
    debugPrint(jsonString);
    return jsonString;
  } catch (e) {
    throw Exception('Failed to load local JSON file: $e');
  }
}

// ฟังก์ชันสำหรับ POST ข้อมูล (จำลองการเพิ่มข้อมูล)
Future<String> postData(Map<String, dynamic> data) async {
  try {
    // จำลองการ POST โดยไม่ส่งข้อมูลจริง
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
void deleteGrowing(List<Growing> growings, int growingId, Function updateUI) {
  growings.removeWhere((growing) => growing.growingId == growingId);
  updateUI();
}

// ฟังก์ชันสำหรับแก้ไขข้อมูล Growing
void editGrowing(
    List<Growing> growings, int growingId, int newFarmId, Function updateUI) {
  Growing growing =
      growings.firstWhere((growing) => growing.growingId == growingId);
  growing.farmId = newFarmId;
  updateUI();
}

// แปลง JSON เป็น Growing List
List<Growing> parseGrowings(String jsonStr) {
  final List<dynamic> jsonData = json.decode(jsonStr);
  return jsonData.map((data) => Growing.fromJson(data)).toList();
}

class GrowingPage extends StatefulWidget {
  const GrowingPage({super.key});

  @override
  State<GrowingPage> createState() => _GrowingPageState();
}

class _GrowingPageState extends State<GrowingPage> {
  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<Growing> growings = []; // สำหรับเก็บ List ของ Growing

  void _loadData() async {
    try {
      String jsonData = await fetchData();
      setState(() {
        growings = parseGrowings(jsonData); // แปลง JSON เป็น Growing List
        data = jsonData; // เก็บข้อมูล JSON
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  // ฟังก์ชันเพิ่มข้อมูลหลอกเข้าไปใน List<Growing>
  void _addFakeGrowing() {
    final fakeGrowing = Growing(
      growingId: growings.isEmpty ? 101 : growings.last.growingId + 1,
      farmId: growings.isEmpty ? 1 : growings.last.farmId + 1,
    );
    setState(() {
      growings.add(fakeGrowing);
    });
  }

  // ฟังก์ชันสำหรับเปิด modal แก้ไขข้อมูล Growing
  void _openEditModal(Growing growing) {
    final TextEditingController farmIdController =
        TextEditingController(text: growing.farmId.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Growing'),
          content: TextField(
            controller: farmIdController,
            decoration: const InputDecoration(labelText: 'Farm ID'),
            keyboardType: TextInputType.number,
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
                int newFarmId =
                    int.tryParse(farmIdController.text) ?? growing.farmId;
                editGrowing(growings, growing.growingId, newFarmId, () {
                  setState(() {});
                });
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
            // ถ้ามีข้อมูล Growing ให้แสดงใน ListView
            if (growings.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: growings.length,
                  itemBuilder: (context, index) {
                    final growing = growings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(growing.growingId.toString()),
                        ),
                        title: Text('Growing ID: ${growing.growingId}'),
                        subtitle: Text('Farm ID: ${growing.farmId}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ปุ่ม Edit
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _openEditModal(growing);
                              },
                            ),
                            // ปุ่ม Delete
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteGrowing(growings, growing.growingId, () {
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
            // แสดงข้อมูล JSON หากไม่มี Growing
            if (data.isNotEmpty && growings.isEmpty)
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
              onPressed: _addFakeGrowing,
              child: const Text('Post Data'),
            ),
          ],
        ),
      ),
    );
  }
}

// Class สำหรับแปลง JSON
class Growing {
  final int growingId;
  int farmId;

  Growing({required this.growingId, required this.farmId});

  factory Growing.fromJson(Map<String, dynamic> json) {
    return Growing(
      growingId: json['growing_id'],
      farmId: json['farm_id'],
    );
  }
}
