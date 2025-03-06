import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String url = 'assets/devices.json';
const String apiUrl = 'http://192.168.1.120:5000/api/device';

// ฟังก์ชันโหลดข้อมูลจาก API
Future<String> fetchData() async {
  try {
    final response = await http.get(Uri.parse(apiUrl));
    print(response);
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

// ฟังก์ชันสำหรับ POST ข้อมูลไปยัง API
Future<String> postData(Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
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

// ฟังก์ชันสำหรับ PUT ข้อมูลไปยัง API
Future<String> putData(Map<String, dynamic> data) async {
  try {
    final response = await http.put(
      Uri.parse(apiUrl),
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

// ฟังก์ชันสำหรับ DELETE ข้อมูลจาก API
Future<void> deleteData(int deviceId) async {
  try {
    final deleteUrl = '$apiUrl/$deviceId';
    final response = await http.delete(Uri.parse(deleteUrl));
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to delete data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to delete data: $e');
  }
}

// ฟังก์ชันสำหรับแก้ไขข้อมูลอุปกรณ์
void editDevice(List<Device> devices, int deviceId, String newName,
    String newDescription, String newStatus, Function updateUI) {
  Device device = devices.firstWhere((device) => device.device_id == deviceId);
  device.device_name = newName;
  device.description = newDescription;
  device.status = newStatus;
  updateUI();
}

// ฟังก์ชันสำหรับ DELETE ข้อมูล (ลบข้อมูลจาก UI และ API)
void deleteDevice(List<Device> devices, int deviceId, Function updateUI) async {
  try {
    await deleteData(deviceId);
    devices.removeWhere((device) => device.device_id == deviceId);
    updateUI();
  } catch (e) {
    throw Exception('Failed to delete device: $e');
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

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<Device> devices = []; // สำหรับเก็บ List ของ Device

  void _loadData() async {
    try {
      String jsonData = await fetchData();
      setState(() {
        devices = parseDevices(jsonData); // แปลง JSON เป็น Device List
        data = jsonData; // เก็บข้อมูล JSON
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  // ฟังก์ชันเพิ่มข้อมูลหลอกเข้าไปใน List<Device>
  void _addFakeDevice() {
    final fakeDevice = Device(
      device_id: devices.length + 10001, // device_id เริ่มจาก 10001
      device_name: 'Sensor_${devices.length + 1}',
      description: 'Fake Sensor ${devices.length + 1}',
      status: 'active',
    );
    setState(() {
      devices.add(fakeDevice); // เพิ่มข้อมูลหลอก
    });
  }

  // ฟังก์ชันสำหรับเปิด modal แก้ไขข้อมูลอุปกรณ์
  void _openEditModal(Device device) {
    final TextEditingController nameController =
        TextEditingController(text: device.device_name);
    final TextEditingController descriptionController =
        TextEditingController(text: device.description);
    final TextEditingController statusController =
        TextEditingController(text: device.status);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'Status'),
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
                // เรียกฟังก์ชันแก้ไขข้อมูล
                editDevice(
                  devices,
                  device.device_id,
                  nameController.text,
                  descriptionController.text,
                  statusController.text,
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
            if (devices.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(device.device_id.toString()),
                        ),
                        title: Text(device.device_name),
                        subtitle: Text(
                            'Description: ${device.description}\nStatus: ${device.status}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ปุ่ม Edit
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _openEditModal(device);
                              },
                            ),
                            // ปุ่ม Delete
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteDevice(devices, device.device_id, () {
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
            if (data.isNotEmpty && devices.isEmpty)
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
              onPressed: _addFakeDevice,
              child: const Text('Post Data'),
            ),
          ],
        ),
      ),
    );
  }
}

// Class สำหรับแปลง JSON
class Device {
  final int device_id;
  String device_name;
  String description;
  String status;

  Device({
    required this.device_id,
    required this.device_name,
    required this.description,
    required this.status,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      device_id: json['device_id'],
      device_name: json['device_name'],
      description: json['description'],
      status: json['status'],
    );
  }
}
