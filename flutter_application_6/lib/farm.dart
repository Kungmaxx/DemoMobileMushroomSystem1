import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String url = 'assets/farms.json';
const String urlApi = 'http://192.168.1.120:5000/api/farm';

// ฟังก์ชันโหลดข้อมูล JSON สำหรับ farm
Future<String> fetchFarmData() async {
  try {
    final response = await http.get(Uri.parse(urlApi));
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

// ฟังก์ชันสำหรับ POST farm (ตัวอย่างส่ง HTTP request)
Future<String> postFarmData(Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse(urlApi),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      print("postFarmData 201");
      return response.body;
    } else {
      throw Exception(
          'Failed to post farm data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to post farm data: $e');
  }
}

// ฟังก์ชันสำหรับ PUT farm (ตัวอย่างส่ง HTTP request)
Future<String> putFarmData(Map<String, dynamic> data) async {
  try {
    final response = await http.put(
      Uri.parse(urlApi),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print("putFarmData 200");
      return response.body;
    } else {
      throw Exception(
          'Failed to update farm data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to update farm data: $e');
  }
}

// ฟังก์ชันสำหรับ DELETE farm (ลบข้อมูลจาก UI)
void deleteFarm(List<FarmData> farms, int farmId, Function updateUI) {
  farms.removeWhere((farm) => farm.farm_id == farmId);
  updateUI();
}

// แปลง JSON เป็น FarmData List
List<FarmData> parseFarms(String jsonStr) {
  final decoded = json.decode(jsonStr);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    final List<dynamic> list = decoded['data'];
    return list.map((data) => FarmData.fromJson(data)).toList();
  } else {
    throw Exception("Unexpected JSON format");
  }
}

class FarmPage extends StatefulWidget {
  const FarmPage({super.key});

  @override
  _FarmPageState createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<FarmData> farms = []; // สำหรับเก็บ List ของ FarmData

  void _loadFarmData() async {
    try {
      String jsonData = await fetchFarmData();
      setState(() {
        farms = parseFarms(jsonData)
            .cast<FarmData>(); // แปลง JSON เป็น FarmData List
        data = jsonData;
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  // ฟังก์ชันเพิ่มข้อมูลหลอกเข้าไปใน List<FarmData>
  void _addFakeFarm() {
    final fakeFarm = FarmData(
      farm_id: farms.length + 1,
      farm_name: 'New Farm ${farms.length + 1}',
      farm_type: 'Unknown',
      farm_description: 'Description of New Farm ${farms.length + 1}',
      farm_status: 1,
      temperature: 20.0,
      humidity: 50.0,
    );
    setState(() {
      farms.add(fakeFarm);
    });
  }

  // ฟังก์ชันสำหรับเปิด modal แก้ไขข้อมูลของฟาร์ม
  void _openEditModal(FarmData farm) {
    final TextEditingController nameController =
        TextEditingController(text: farm.farm_name);
    final TextEditingController typeController =
        TextEditingController(text: farm.farm_type);
    final TextEditingController descriptionController =
        TextEditingController(text: farm.farm_description);
    final TextEditingController statusController =
        TextEditingController(text: farm.farm_status.toString());
    final TextEditingController tempController =
        TextEditingController(text: farm.temperature.toString());
    final TextEditingController humidityController =
        TextEditingController(text: farm.humidity.toString());

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Farm'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Farm Name'),
                  ),
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: 'Farm Type'),
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
                  TextField(
                    controller: tempController,
                    decoration: const InputDecoration(labelText: 'Temperature'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: humidityController,
                    decoration: const InputDecoration(labelText: 'Humidity'),
                    keyboardType: TextInputType.number,
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
                  setState(() {
                    int index =
                        farms.indexWhere((f) => f.farm_id == farm.farm_id);
                    if (index != -1) {
                      farms[index] = FarmData(
                        farm_id: farm.farm_id,
                        farm_name: nameController.text,
                        farm_type: typeController.text,
                        farm_description: descriptionController.text,
                        farm_status: int.tryParse(statusController.text) ??
                            farm.farm_status,
                        temperature: double.tryParse(tempController.text) ??
                            farm.temperature,
                        humidity: double.tryParse(humidityController.text) ??
                            farm.humidity,
                      );
                    }
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (farms.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    final farm = farms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading:
                            CircleAvatar(child: Text(farm.farm_id.toString())),
                        title: Text(farm.farm_name),
                        subtitle: Text(
                          'Type: ${farm.farm_type}\n'
                          'Desc: ${farm.farm_description}\n'
                          'Temp: ${farm.temperature}, Humidity: ${farm.humidity}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ปุ่ม Edit
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _openEditModal(farm);
                              },
                            ),
                            // ปุ่ม Delete
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteFarm(farms, farm.farm_id, () {
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
            if (data.isNotEmpty && farms.isEmpty)
              Text(
                data,
                style: const TextStyle(fontSize: 18),
              ),
            ElevatedButton(
              onPressed: _loadFarmData,
              child: const Text('GET Farm Data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFakeFarm,
              child: const Text('Post Farm Data'),
            ),
          ],
        ),
      ),
    );
  }
}

class FarmData {
  final int farm_id;
  final String farm_name;
  final String farm_type;
  final String farm_description;
  final int farm_status;
  final double temperature;
  final double humidity;

  FarmData({
    required this.farm_id,
    required this.farm_name,
    required this.farm_type,
    required this.farm_description,
    required this.farm_status,
    required this.temperature,
    required this.humidity,
  });

  factory FarmData.fromJson(Map<String, dynamic> json) {
    return FarmData(
      farm_id: json['farm_id'],
      farm_name: json['farm_name'],
      farm_type: json['farm_type'],
      farm_description: json['farm_description'],
      farm_status: json['farm_status'] is bool
          ? (json['farm_status'] ? 1 : 0)
          : json['farm_status'],
      temperature: json['temperature'] != null
          ? (json['temperature'] as num).toDouble()
          : 0.0,
      humidity:
          json['humidity'] != null ? (json['humidity'] as num).toDouble() : 0.0,
    );
  }
}
