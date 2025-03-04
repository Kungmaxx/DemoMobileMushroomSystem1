import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const String url = 'assets/cultivation.json';

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
void deleteCultivation(
    List<Cultivation> cultivations, int cultivationId, Function updateUI) {
  cultivations.removeWhere((item) => item.cultivation_id == cultivationId);
  updateUI();
}

// ฟังก์ชันสำหรับแก้ไขข้อมูล Cultivation
void editCultivation(List<Cultivation> cultivations, int cultivationId,
    int newFarmId, Function updateUI) {
  Cultivation item =
      cultivations.firstWhere((item) => item.cultivation_id == cultivationId);
  item.farm_id = newFarmId;
  updateUI();
}

// แปลง JSON เป็น List<Cultivation>
List<Cultivation> parseCultivations(String jsonStr) {
  final List<dynamic> jsonData = json.decode(jsonStr);
  return jsonData.map((data) => Cultivation.fromJson(data)).toList();
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
    );
    setState(() {
      cultivations.add(fakeCultivation);
    });
  }

  // ฟังก์ชันเปิด modal แก้ไข farm_id
  void _openEditModal(Cultivation item) {
    final TextEditingController farmIdController =
        TextEditingController(text: item.farm_id.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Cultivation'),
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
                    int.tryParse(farmIdController.text) ?? item.farm_id;
                editCultivation(cultivations, item.cultivation_id, newFarmId,
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
                        subtitle: Text('Farm ID: ${item.farm_id}'),
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

  Cultivation({
    required this.cultivation_id,
    required this.farm_id,
  });

  factory Cultivation.fromJson(Map<String, dynamic> json) {
    return Cultivation(
      cultivation_id: json['cultivation_id'],
      farm_id: json['farm_id'],
    );
  }
}
