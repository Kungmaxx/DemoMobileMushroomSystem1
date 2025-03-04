import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const String url = 'assets/growingpotdata.json';

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
void deleteGrowingPot(List<GrowingPot> pots, int potId, Function updateUI) {
  pots.removeWhere((pot) => pot.growingPotId == potId);
  updateUI();
}

// ฟังก์ชันสำหรับแก้ไขข้อมูล GrowingPot (แก้ไข ai_result, deviceName, mushroomType, growingId)
void editGrowingPot(
  List<GrowingPot> pots,
  int potId,
  String newAiResult,
  String newDeviceName,
  String newMushroomType,
  int newGrowingId,
  Function updateUI,
) {
  GrowingPot pot = pots.firstWhere((pot) => pot.growingPotId == potId);
  pot.aiResult = newAiResult;
  pot.device.deviceName = newDeviceName;
  pot.mushroom.typePotName = newMushroomType;
  pot.growing.growingId = newGrowingId;
  updateUI();
}

// แปลง JSON เป็น List<GrowingPot>
List<GrowingPot> parseGrowingPots(String jsonStr) {
  final Map<String, dynamic> jsonData = json.decode(jsonStr);
  final List<dynamic> list = jsonData['growingpots'];
  return list.map((data) => GrowingPot.fromJson(data)).toList();
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
      index: pots.isEmpty ? 1 : pots.last.index + 1,
      imgPath: 'path/to/fake_image.jpg',
      aiResult: 'ผลการวิเคราะห์ AI - ดี',
      status: 'active',
      device: Device(
        deviceId: 10000,
        deviceName: 'Fake Sensor',
        description: 'Fake sensor description',
        status: 'active',
      ),
      mushroom: Mushroom(
        typePotId: 111100,
        typePotName: 'Fake Mushroom',
        description: 'Fake mushroom description',
        status: 1,
      ),
      growing: Growing(
        growingId: 100,
        farm: Farm(
          farmId: 1,
          farmName: 'Fake Farm',
          farmType: 'Fake Type',
          farmDescription: 'Fake farm description',
          farmStatus: 1,
          temperature: 25.0,
          humidity: 50.0,
        ),
      ),
    );
    setState(() {
      pots.add(fakePot);
    });
  }

  // ฟังก์ชันสำหรับเปิด modal แก้ไขข้อมูล GrowingPot
  void _openEditModal(GrowingPot pot) {
    final TextEditingController aiResultController =
        TextEditingController(text: pot.aiResult);
    final TextEditingController deviceNameController =
        TextEditingController(text: pot.device.deviceName);
    final TextEditingController mushroomTypeController =
        TextEditingController(text: pot.mushroom.typePotName);
    final TextEditingController growingIdController =
        TextEditingController(text: pot.growing.growingId.toString());

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
                  controller: deviceNameController,
                  decoration: const InputDecoration(labelText: 'Device Name'),
                ),
                TextField(
                  controller: mushroomTypeController,
                  decoration: const InputDecoration(labelText: 'Mushroom Type'),
                ),
                TextField(
                  controller: growingIdController,
                  decoration: const InputDecoration(labelText: 'Growing ID'),
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
                int newGrowingId = int.tryParse(growingIdController.text) ??
                    pot.growing.growingId;
                editGrowingPot(
                  pots,
                  pot.growingPotId,
                  aiResultController.text,
                  deviceNameController.text,
                  mushroomTypeController.text,
                  newGrowingId,
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
                            Text('Device: ${pot.device.deviceName}'),
                            Text('Mushroom: ${pot.mushroom.typePotName}'),
                            Text('Growing ID: ${pot.growing.growingId}'),
                            Text('Farm: ${pot.growing.farm.farmName}'),
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
  final int index;
  final String imgPath;
  String aiResult;
  final String status;
  final Device device;
  final Mushroom mushroom;
  final Growing growing;

  GrowingPot({
    required this.growingPotId,
    required this.index,
    required this.imgPath,
    required this.aiResult,
    required this.status,
    required this.device,
    required this.mushroom,
    required this.growing,
  });

  factory GrowingPot.fromJson(Map<String, dynamic> json) {
    return GrowingPot(
      growingPotId: json['growing_pot_id'],
      index: json['index'],
      imgPath: json['img_path'],
      aiResult: json['ai_result'],
      status: json['status'],
      device: Device.fromJson(json['device']),
      mushroom: Mushroom.fromJson(json['mushroom']),
      growing: Growing.fromJson(json['growing']),
    );
  }
}

class Device {
  final int deviceId;
  String deviceName;
  final String description;
  final String status;

  Device({
    required this.deviceId,
    required this.deviceName,
    required this.description,
    required this.status,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      description: json['description'],
      status: json['status'],
    );
  }
}

class Mushroom {
  final int typePotId;
  String typePotName;
  final String description;
  final int status;

  Mushroom({
    required this.typePotId,
    required this.typePotName,
    required this.description,
    required this.status,
  });

  factory Mushroom.fromJson(Map<String, dynamic> json) {
    return Mushroom(
      typePotId: json['type_pot_id'],
      typePotName: json['type_pot_name'],
      description: json['description'],
      status: json['status'],
    );
  }
}

class Growing {
  int growingId;
  final Farm farm;

  Growing({
    required this.growingId,
    required this.farm,
  });

  factory Growing.fromJson(Map<String, dynamic> json) {
    return Growing(
      growingId: json['growing_id'],
      farm: Farm.fromJson(json['farm']),
    );
  }
}

class Farm {
  final int farmId;
  String farmName;
  final String farmType;
  final String farmDescription;
  final int farmStatus;
  final double temperature;
  final double humidity;

  Farm({
    required this.farmId,
    required this.farmName,
    required this.farmType,
    required this.farmDescription,
    required this.farmStatus,
    required this.temperature,
    required this.humidity,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      farmId: json['farm_id'],
      farmName: json['farm_name'],
      farmType: json['farm_type'],
      farmDescription: json['farm_description'],
      farmStatus: json['farm_status'],
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
    );
  }
}
