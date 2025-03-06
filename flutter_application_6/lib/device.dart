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
Future<void> postData(Device newDevice, Function _loadData) async {
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'device_name': newDevice.device_name,
        'description': newDevice.description,
        'device_type': newDevice.device_type,
        'status': newDevice.status,
      }),
    );
    if (response.statusCode == 201) {
      print("postData 201");
      // Reload data after adding
      _loadData();
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
Future<void> editDevice(
    BuildContext context,
    Device device,
    String newName,
    String newDescription,
    String newType,
    String newStatus,
    Function updateUI) async {
  if (newName.isEmpty || newDescription.isEmpty || newStatus.isEmpty) {
    // Show an alert if any field is empty
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill in all fields'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return;
  }

  try {
    final response = await http.put(
      Uri.parse('$apiUrl/${device.device_id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'device_name': newName,
        'description': newDescription,
        'device_type': newType,
        'status': newStatus,
      }),
    );

    if (response.statusCode == 200) {
      device.device_name = newName;
      device.description = newDescription;
      device.device_type = newType;
      device.status = newStatus;
      updateUI();
    } else {
      throw Exception(
          'Failed to update data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to update data: $e');
  }
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
  @override
  void initState() {
    super.initState();
    _loadData(); // Call _loadData when the page is initialized
  }

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

  // ฟังก์ชันสำหรับเปิด modal แก้ไขข้อมูลอุปกรณ์
  void _openEditModal(Device device) {
    final TextEditingController nameController =
        TextEditingController(text: device.device_name);
    final TextEditingController descriptionController =
        TextEditingController(text: device.description);
    String selectedType = device.device_type;
    String selectedStatus = device.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Device'),
          content: SingleChildScrollView(
            child: Column(
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
                DropdownButtonFormField<String>(
                  value: selectedType.isEmpty ? null : selectedType,
                  decoration: const InputDecoration(labelText: 'Device Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'เครื่องเพาะ',
                      child: Text('เครื่องเพาะ'),
                    ),
                    DropdownMenuItem(
                      value: 'เครื่องปลูก',
                      child: Text('เครื่องปลูก'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? '';
                    });
                  },
                  hint: const Text('Select Device Type'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus.isEmpty ? null : selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value ?? '';
                    });
                  },
                  hint: const Text('Select Status'),
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
              onPressed: () async {
                await editDevice(
                  context,
                  device,
                  nameController.text,
                  descriptionController.text,
                  selectedType,
                  selectedStatus,
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

  // ฟังก์ชันสำหรับเปิด modal เพิ่มข้อมูลอุปกรณ์
  void _openAddModal() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedType = '';
    String selectedStatus = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Device'),
          content: SingleChildScrollView(
            child: Column(
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
                DropdownButtonFormField<String>(
                  value: selectedType.isEmpty ? null : selectedType,
                  decoration: const InputDecoration(labelText: 'Device Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'เครื่องเพาะ',
                      child: Text('เครื่องเพาะ'),
                    ),
                    DropdownMenuItem(
                      value: 'เครื่องปลูก',
                      child: Text('เครื่องปลูก'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? '';
                    });
                  },
                  hint: const Text('Select Device Type'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus.isEmpty ? null : selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value ?? '';
                    });
                  },
                  hint: const Text('Select Status'),
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
              onPressed: () async {
                final newDevice = Device(
                  device_id:
                      devices.isNotEmpty ? devices.last.device_id + 1 : 1,
                  device_name: nameController.text,
                  description: descriptionController.text,
                  device_type: selectedType,
                  status: selectedStatus,
                );
                await postData(newDevice, _loadData);
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
                          'Description: ${device.description}\n'
                          'Device Type: ${device.device_type}\n'
                          'Status: ${device.status}',
                        ),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openAddModal,
              child: const Text('POST Data'),
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
  String device_type;
  String status;

  Device({
    required this.device_id,
    required this.device_name,
    required this.description,
    required this.device_type,
    required this.status,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    String rawStatus = json['status'] ?? '';
    // แปลงให้เป็น "Active"/"Inactive"
    String capitalizedStatus =
        rawStatus.toLowerCase() == 'active' ? 'Active' : 'Inactive';

    String rawType = json['device_type'] ?? '';
    // แปลงให้เป็น "เครื่องเพาะ"/"เครื่องปลูก"
    String translatedType = rawType.toLowerCase() == 'cultivation'
        ? 'เครื่องเพาะ'
        : rawType.toLowerCase() == 'growing'
            ? 'เครื่องปลูก'
            : rawType;

    return Device(
      device_id: json['device_id'],
      device_name: json['device_name'] ?? '',
      description: json['description'] ?? '',
      device_type: translatedType,
      status: capitalizedStatus,
    );
  }
}
