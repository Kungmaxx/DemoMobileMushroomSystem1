import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String url = 'http://192.168.1.120:5000/api/viewGrowing/1';

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
Future<void> deleteData(int growingPotId) async {
  try {
    final deleteUrl = '$url/$growingPotId';
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
void deleteGrowingPot(
    List<GrowingPot> pots, int potId, Function updateUI) async {
  try {
    await deleteData(potId);
    pots.removeWhere((pot) => pot.growingPotId == potId);
    updateUI();
  } catch (e) {
    throw Exception('Failed to delete growing pot: $e');
  }
}

// ฟังก์ชันสำหรับแก้ไขข้อมูล GrowingPot (แก้ไข ai_result, pot_name)
void editGrowingPot(List<GrowingPot> pots, int potId, String newAiResult,
    String newPotName, Function updateUI) {
  GrowingPot pot = pots.firstWhere((pot) => pot.growingPotId == potId);
  pot.aiResult = newAiResult;
  pot.potName = newPotName;
  updateUI();
}

// แปลง JSON เป็น List<GrowingPot>
List<GrowingPot> parseGrowingPots(String jsonStr) {
  final decoded = json.decode(jsonStr);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    final List<dynamic> list = decoded['data'];
    return list.map((data) => GrowingPot.fromJson(data)).toList();
  } else {
    throw Exception("Unexpected JSON format");
  }
}

class GrowingpotPage extends StatefulWidget {
  const GrowingpotPage({super.key});

  @override
  State<GrowingpotPage> createState() => _GrowingpotPageState();
}

class _GrowingpotPageState extends State<GrowingpotPage> {
  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<GrowingPot> pots = []; // สำหรับเก็บ List ของ GrowingPot

  void _loadData() async {
    try {
      String jsonData = await fetchData();
      setState(() {
        pots = parseGrowingPots(jsonData);
        data = jsonData;
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  // ฟังก์ชันเพิ่มข้อมูลหลอกเข้าไปใน List<GrowingPot>
  void _addFakeGrowingPot() {
    final fakePot = GrowingPot(
      growingPotId: pots.isEmpty ? 1013 : pots.last.growingPotId + 1,
      growingId: 1,
      typePotId: 111100,
      index: pots.isEmpty ? 1 : pots.last.index + 1,
      imgPath: 'path/to/fake_image.jpg',
      aiResult: 'ผลการวิเคราะห์ AI - ดี',
      status: 'active',
      potName: 'Fake Pot Name',
      typePotName: 'Fake Type Pot Name',
    );
    setState(() {
      pots.add(fakePot);
    });
  }

  // ฟังก์ชันสำหรับเปิด modal แก้ไขข้อมูล GrowingPot
  void _openEditModal(GrowingPot pot) {
    final TextEditingController aiResultController =
        TextEditingController(text: pot.aiResult);
    final TextEditingController potNameController =
        TextEditingController(text: pot.potName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit GrowingPot'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: aiResultController,
                  decoration: const InputDecoration(labelText: 'AI Result'),
                ),
                TextField(
                  controller: potNameController,
                  decoration: const InputDecoration(labelText: 'Pot Name'),
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
              onPressed: () {
                editGrowingPot(
                  pots,
                  pot.growingPotId,
                  aiResultController.text,
                  potNameController.text,
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
            if (pots.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: pots.length,
                  itemBuilder: (context, index) {
                    final pot = pots[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(pot.growingPotId.toString()),
                        ),
                        title: Text('Growing Pot ID: ${pot.growingPotId}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI Result: ${pot.aiResult}'),
                            Text('Pot Name: ${pot.potName}'),
                            Text('Type Pot ID: ${pot.typePotId}'),
                            Text('Index: ${pot.index}'),
                            Text('Status: ${pot.status}'),
                            Text('Type Pot Name: ${pot.typePotName}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _openEditModal(pot);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteGrowingPot(pots, pot.growingPotId, () {
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
            if (data.isNotEmpty && pots.isEmpty)
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
              onPressed: _addFakeGrowingPot,
              child: const Text('Post Data'),
            ),
          ],
        ),
      ),
    );
  }
}

// Model Classes

class GrowingPot {
  final int growingPotId;
  final int growingId;
  final int typePotId;
  final int index;
  final String imgPath;
  String aiResult;
  final String status;
  String potName;
  final String typePotName;

  GrowingPot({
    required this.growingPotId,
    required this.growingId,
    required this.typePotId,
    required this.index,
    required this.imgPath,
    required this.aiResult,
    required this.status,
    required this.potName,
    required this.typePotName,
  });

  factory GrowingPot.fromJson(Map<String, dynamic> json) {
    return GrowingPot(
      growingPotId: json['growing_pot_id'],
      growingId: json['growing_id'],
      typePotId: json['type_pot_id'],
      index: json['index'] ?? 0,
      imgPath: json['img_path'] ?? '',
      aiResult: json['ai_result'] ?? '',
      status: json['status'],
      potName: json['pot_name'] ?? '',
      typePotName:
          json['typePot'] != null ? json['typePot']['type_pot_name'] : '',
    );
  }
}
