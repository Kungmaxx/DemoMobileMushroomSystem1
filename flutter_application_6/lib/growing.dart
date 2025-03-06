import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String url = 'http://192.168.1.120:5000/api/growing';

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

// ฟังก์ชันสำหรับ PUT ข้อมูล (จำลองการแก้ไขข้อมูล)
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

// ฟังก์ชันสำหรับ DELETE ข้อมูล (ลบข้อมูลจาก UI)
Future<void> deleteData(int growingId) async {
  try {
    final deleteUrl = '$url/$growingId';
    final response = await http.delete(Uri.parse(deleteUrl));
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to delete data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to delete data: $e');
  }
}

// ฟังก์ชันสำหรับ DELETE ข้อมูล (ลบข้อมูลจาก UI และ API)
void deleteGrowing(
    List<Growing> growings, int growingId, Function updateUI) async {
  try {
    await deleteData(growingId);
    growings.removeWhere((growing) => growing.growingId == growingId);
    updateUI();
  } catch (e) {
    throw Exception('Failed to delete growing: $e');
  }
}

// ฟังก์ชันสำหรับแก้ไขข้อมูล Growing
void editGrowing(List<Growing> growings, int growingId, int newFarmId,
    int newDeviceId, Function updateUI) {
  Growing growing =
      growings.firstWhere((growing) => growing.growingId == growingId);
  growing.farmId = newFarmId;
  growing.deviceId = newDeviceId;
  updateUI();
}

// แปลง JSON เป็น Growing List
List<Growing> parseGrowings(String jsonStr) {
  final decoded = json.decode(jsonStr);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    final List<dynamic> list = decoded['data'];
    return list.map((data) => Growing.fromJson(data)).toList();
  } else {
    throw Exception("Unexpected JSON format");
  }
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
      deviceId: growings.isEmpty ? 1 : growings.last.deviceId + 1,
    );
    setState(() {
      growings.add(fakeGrowing);
    });
  }

  // ฟังก์ชันสำหรับเปิด modal แก้ไขข้อมูล Growing
  void _openEditModal(Growing growing) {
    final TextEditingController farmIdController =
        TextEditingController(text: growing.farmId.toString());
    final TextEditingController deviceIdController =
        TextEditingController(text: growing.deviceId.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Growing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: farmIdController,
                decoration: const InputDecoration(labelText: 'Farm ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: deviceIdController,
                decoration: const InputDecoration(labelText: 'Device ID'),
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
                int newFarmId =
                    int.tryParse(farmIdController.text) ?? growing.farmId;
                int newDeviceId =
                    int.tryParse(deviceIdController.text) ?? growing.deviceId;
                editGrowing(growings, growing.growingId, newFarmId, newDeviceId,
                    () {
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
                        subtitle: Text(
                            'Farm ID: ${growing.farmId}\nDevice ID: ${growing.deviceId}'),
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
  int deviceId;

  Growing(
      {required this.growingId, required this.farmId, required this.deviceId});

  factory Growing.fromJson(Map<String, dynamic> json) {
    return Growing(
      growingId: json['growing_id'],
      farmId: json['farm_id'],
      deviceId: json['device_id'],
    );
  }
}
