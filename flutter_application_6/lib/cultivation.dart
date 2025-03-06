import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String url = 'http://192.168.1.120:5000/api/cultivation';

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

// ฟังก์ชันสำหรับ POST ข้อมูล
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

// ฟังก์ชันสำหรับ PUT ข้อมูล
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

// ฟังก์ชันสำหรับ DELETE ข้อมูล
Future<void> deleteData(int cultivationId) async {
  try {
    final deleteUrl = '$url/$cultivationId';
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
void deleteCultivation(List<Cultivation> cultivations, int cultivationId,
    Function updateUI) async {
  try {
    await deleteData(cultivationId);
    cultivations.removeWhere((item) => item.cultivation_id == cultivationId);
    updateUI();
  } catch (e) {
    throw Exception('Failed to delete cultivation: $e');
  }
}

// ฟังก์ชันสำหรับแก้ไขข้อมูล Cultivation
void editCultivation(List<Cultivation> cultivations, int cultivationId,
    int newFarmId, int newDeviceId, Function updateUI) {
  Cultivation item =
      cultivations.firstWhere((item) => item.cultivation_id == cultivationId);
  item.farm_id = newFarmId;
  item.device_id = newDeviceId;
  updateUI();
}

// แปลง JSON เป็น List<Cultivation>
List<Cultivation> parseCultivations(String jsonStr) {
  final decoded = json.decode(jsonStr);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    final List<dynamic> list = decoded['data'];
    return list.map((data) => Cultivation.fromJson(data)).toList();
  } else {
    throw Exception("Unexpected JSON format");
  }
}

class CultivationPage extends StatefulWidget {
  const CultivationPage({super.key});

  @override
  State<CultivationPage> createState() => _CultivationPageState();
}

class _CultivationPageState extends State<CultivationPage> {
  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<Cultivation> cultivations = []; // สำหรับเก็บ List ของ cultivation

  void _loadData() async {
    try {
      String jsonData = await fetchData();
      setState(() {
        cultivations = parseCultivations(jsonData);
        data = jsonData;
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  // ฟังก์ชันเพิ่มข้อมูลหลอก
  void _addFakeCultivation() {
    final fakeCultivation = Cultivation(
      cultivation_id: cultivations.length + 1,
      farm_id: cultivations.isEmpty ? 1 : cultivations.last.farm_id + 1,
      device_id: cultivations.isEmpty ? 1 : cultivations.last.device_id + 1,
    );
    setState(() {
      cultivations.add(fakeCultivation);
    });
  }

  // ฟังก์ชันเปิด modal แก้ไข farm_id และ device_id
  void _openEditModal(Cultivation item) {
    final TextEditingController farmIdController =
        TextEditingController(text: item.farm_id.toString());
    final TextEditingController deviceIdController =
        TextEditingController(text: item.device_id.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Cultivation'),
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
                    int.tryParse(farmIdController.text) ?? item.farm_id;
                int newDeviceId =
                    int.tryParse(deviceIdController.text) ?? item.device_id;
                editCultivation(
                    cultivations, item.cultivation_id, newFarmId, newDeviceId,
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
            if (cultivations.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: cultivations.length,
                  itemBuilder: (context, index) {
                    final item = cultivations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(item.cultivation_id.toString()),
                        ),
                        title: Text('Cultivation ID: ${item.cultivation_id}'),
                        subtitle: Text(
                            'Farm ID: ${item.farm_id}\nDevice ID: ${item.device_id}'),
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
                                deleteCultivation(
                                    cultivations, item.cultivation_id, () {
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
            if (data.isNotEmpty && cultivations.isEmpty)
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
              onPressed: _addFakeCultivation,
              child: const Text('Post Data'),
            ),
          ],
        ),
      ),
    );
  }
}

// Class สำหรับแปลง JSON
class Cultivation {
  final int cultivation_id;
  int farm_id;
  int device_id;

  Cultivation({
    required this.cultivation_id,
    required this.farm_id,
    required this.device_id,
  });

  factory Cultivation.fromJson(Map<String, dynamic> json) {
    return Cultivation(
      cultivation_id: json['cultivation_id'],
      farm_id: json['farm_id'],
      device_id: json['device_id'],
    );
  }
}
