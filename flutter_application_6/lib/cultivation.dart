import 'package:flutter/material.dart';
import 'package:flutter_application_6/cultivationpot.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String url = 'http://192.168.1.100:5000/api/cultivation';
const String deviceUrl = 'http://192.168.1.100:5000/api/device';
const String farmUrl = 'http://192.168.1.100:5000/api/farm';

// ฟังก์ชันโหลดข้อมูล JSON
Future<String> fetchData(String apiUrl) async {
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
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
Future<void> postData(Map<String, dynamic> data, Function _loadData) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
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

// ฟังก์ชันสำหรับ PUT ข้อมูล
Future<void> putData(
    int id, Map<String, dynamic> data, Function _loadData) async {
  try {
    final response = await http.put(
      Uri.parse('$url/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
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

// ฟังก์ชันสำหรับ DELETE ข้อมูล
Future<void> deleteData(int id, Function _loadData) async {
  try {
    final response = await http.delete(
      Uri.parse('$url/$id'),
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
  final int? cultivationId;
  const CultivationPage({super.key, this.cultivationId});

  @override
  State<CultivationPage> createState() => _CultivationPageState();
}

class _CultivationPageState extends State<CultivationPage> {
  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<Cultivation> cultivations = []; // สำหรับเก็บ List ของ cultivation
  List<Device> devices = [];
  List<Farm> farms = [];
  String selectedDevice = '';
  String selectedFarm = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      String cultivationData = await fetchData(url);
      String deviceData = await fetchData(deviceUrl);
      String farmData = await fetchData(farmUrl);

      setState(() {
        cultivations = parseCultivations(cultivationData);
        devices = parseDevices(deviceData);
        farms = parseFarms(farmData);
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  List<Device> parseDevices(String jsonStr) {
    final decoded = json.decode(jsonStr);
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      final List<dynamic> list = decoded['data'];
      return list.map((data) => Device.fromJson(data)).toList();
    } else {
      throw Exception("Unexpected JSON format");
    }
  }

  List<Farm> parseFarms(String jsonStr) {
    final decoded = json.decode(jsonStr);
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      final List<dynamic> list = decoded['data'];
      return list.map((data) => Farm.fromJson(data)).toList();
    } else {
      throw Exception("Unexpected JSON format");
    }
  }

  void _openEditModal(Cultivation item) {
    String selectedDevice =
        devices.firstWhere((d) => d.device_id == item.device_id).device_name;
    String selectedFarm =
        farms.firstWhere((f) => f.farm_id == item.farm_id).farm_name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Cultivation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedFarm,
                decoration: const InputDecoration(labelText: 'Farm Name'),
                items: farms.map((farm) {
                  return DropdownMenuItem(
                    value: farm.farm_name,
                    child: Text(farm.farm_name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFarm = value ?? '';
                  });
                },
                hint: const Text('Select Farm Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedDevice,
                decoration: const InputDecoration(labelText: 'Device Name'),
                items: devices.map((device) {
                  return DropdownMenuItem(
                    value: device.device_name,
                    child: Text(device.device_name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDevice = value ?? '';
                  });
                },
                hint: const Text('Select Device Name'),
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
              onPressed: () async {
                int newFarmId = farms
                    .firstWhere((f) => f.farm_name == selectedFarm)
                    .farm_id;
                int newDeviceId = devices
                    .firstWhere((d) => d.device_name == selectedDevice)
                    .device_id;
                await putData(
                    item.cultivation_id,
                    {
                      'farm_id': newFarmId,
                      'device_id': newDeviceId,
                    },
                    _loadData);
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
    String selectedDevice = devices.isNotEmpty ? devices.first.device_name : '';
    String selectedFarm = farms.isNotEmpty ? farms.first.farm_name : '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Cultivation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedFarm,
                decoration: const InputDecoration(labelText: 'Farm Name'),
                items: farms.map((farm) {
                  return DropdownMenuItem(
                    value: farm.farm_name,
                    child: Text(farm.farm_name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFarm = value ?? '';
                  });
                },
                hint: const Text('Select Farm Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedDevice,
                decoration: const InputDecoration(labelText: 'Device Name'),
                items: devices.map((device) {
                  return DropdownMenuItem(
                    value: device.device_name,
                    child: Text(device.device_name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDevice = value ?? '';
                  });
                },
                hint: const Text('Select Device Name'),
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
              onPressed: () async {
                int newFarmId = farms
                    .firstWhere((f) => f.farm_name == selectedFarm)
                    .farm_id;
                int newDeviceId = devices
                    .firstWhere((d) => d.device_name == selectedDevice)
                    .device_id;
                await postData({
                  'farm_id': newFarmId,
                  'device_id': newDeviceId,
                }, _loadData);
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
                    final deviceName = devices
                        .firstWhere((d) => d.device_id == item.device_id)
                        .device_name;
                    final farmName = farms
                        .firstWhere((f) => f.farm_id == item.farm_id)
                        .farm_name;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(item.cultivation_id.toString()),
                        ),
                        title: Text('Cultivation ID: ${item.cultivation_id}'),
                        subtitle: Text(
                            'Farm Name: $farmName\nDevice Name: $deviceName'),
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
                                deleteData(item.cultivation_id, _loadData);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CultivationpotPage(
                                        cultivationId: item.cultivation_id),
                                  ),
                                );
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

class Device {
  final int device_id;
  final String device_name;

  Device({
    required this.device_id,
    required this.device_name,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      device_id: json['device_id'],
      device_name: json['device_name'],
    );
  }
}

class Farm {
  final int farm_id;
  final String farm_name;

  Farm({
    required this.farm_id,
    required this.farm_name,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      farm_id: json['farm_id'],
      farm_name: json['farm_name'],
    );
  }
}
