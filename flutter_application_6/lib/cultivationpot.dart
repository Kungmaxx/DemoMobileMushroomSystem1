import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http; // Import the new Cultivation class

const String url = 'http://192.168.1.100:5000/api/viewCultivation/48';
const String typePotUrl = 'http://192.168.1.100:5000/api/mushroom';
const String cultivationUrl = 'http://192.168.1.100:5000/api/cultivation';

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
    print('POST Data: $data');
    final response = await http.post(
      Uri.parse('http://192.168.1.120:5000/api/viewCultivation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    print('POST Response: ${response.statusCode} ${response.body}');
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
      Uri.parse('http://192.168.1.120:5000/api/viewCultivation/$id'),
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
      Uri.parse('http://192.168.1.120:5000/api/viewCultivation/$id'),
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

// แปลง JSON เป็น List<CultivationPot>
List<CultivationPot> parseCultivationPots(String jsonStr) {
  final decoded = json.decode(jsonStr);
  print(decoded);
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    final List<dynamic> list = decoded['data'];
    return list.map((data) => CultivationPot.fromJson(data)).toList();
  } else {
    throw Exception("Unexpected JSON format");
  }
}

class CultivationpotPage extends StatefulWidget {
  const CultivationpotPage({super.key});

  @override
  State<CultivationpotPage> createState() => _CultivationpotPageState();
}

class _CultivationpotPageState extends State<CultivationpotPage> {
  String data = ''; // สำหรับเก็บข้อมูล JSON ที่โหลดมา
  List<CultivationPot> pots = []; // สำหรับเก็บ List ของ CultivationPot
  List<TypePot> typePots = [];
  String selectedTypePot = '';
  String selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      String cultivationPotData = await fetchData(url);
      String typePotData = await fetchData(typePotUrl);

      setState(() {
        pots = parseCultivationPots(cultivationPotData);
        typePots = parseTypePots(typePotData);
      });
    } catch (e) {
      setState(() {
        data = 'Failed to load data: $e';
      });
    }
  }

  List<TypePot> parseTypePots(String jsonStr) {
    final decoded = json.decode(jsonStr);
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      final List<dynamic> list = decoded['data'];
      return list.map((data) => TypePot.fromJson(data)).toList();
    } else {
      throw Exception("Unexpected JSON format");
    }
  }

  void _openEditModal(CultivationPot pot) {
    String selectedTypePot =
        typePots.firstWhere((t) => t.typePotId == pot.typePotId).typePotName;
    String selectedStatus = pot.status;
    final TextEditingController potNameController =
        TextEditingController(text: pot.potName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit CultivationPot'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTypePot,
                  decoration: const InputDecoration(labelText: 'Type Pot Name'),
                  items: typePots.map((typePot) {
                    return DropdownMenuItem(
                      value: typePot.typePotName,
                      child: Text(typePot.typePotName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTypePot = value ?? '';
                    });
                  },
                  hint: const Text('Select Type Pot Name'),
                ),
                TextField(
                  controller: potNameController,
                  decoration: const InputDecoration(labelText: 'Pot Name'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: 'safe',
                      child: Text('Safe'),
                    ),
                    DropdownMenuItem(
                      value: 'danger',
                      child: Text('Danger'),
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
                int newTypePotId = typePots
                    .firstWhere((t) => t.typePotName == selectedTypePot)
                    .typePotId;
                print(
                    'PUT Data: ${pot.cultivationPotId}, Type Pot ID: $newTypePotId, Pot Name: ${potNameController.text}, Status: $selectedStatus');
                await putData(
                    pot.cultivationPotId,
                    {
                      'type_pot_id': newTypePotId,
                      'pot_name': potNameController.text,
                      'status': selectedStatus,
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
    String selectedTypePot =
        typePots.isNotEmpty ? typePots.first.typePotName : '';
    String selectedStatus = 'pending';
    final TextEditingController potNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add CultivationPot'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTypePot,
                  decoration: const InputDecoration(labelText: 'Type Pot Name'),
                  items: typePots.map((typePot) {
                    return DropdownMenuItem(
                      value: typePot.typePotName,
                      child: Text(typePot.typePotName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTypePot = value ?? '';
                    });
                  },
                  hint: const Text('Select Type Pot Name'),
                ),
                TextField(
                  controller: potNameController,
                  decoration: const InputDecoration(labelText: 'Pot Name'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: 'safe',
                      child: Text('Safe'),
                    ),
                    DropdownMenuItem(
                      value: 'danger',
                      child: Text('Danger'),
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
                int newTypePotId = typePots
                    .firstWhere((t) => t.typePotName == selectedTypePot)
                    .typePotId;
                await postData({
                  'type_pot_id': newTypePotId,
                  'pot_name': potNameController.text,
                  'status': selectedStatus,
                  'cultivation_id': 48, // Add the cultivation_id field
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

  void _showImageDialog(String imgPath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.network(imgPath),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
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
                    final typePotName = typePots
                        .firstWhere((t) => t.typePotId == pot.typePotId)
                        .typePotName;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(pot.cultivationPotId.toString()),
                        ),
                        title:
                            Text('Cultivation Pot ID: ${pot.cultivationPotId}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pot Name: ${pot.potName}'),
                            Text('Type Pot Name: $typePotName'),
                            Text('Status: ${pot.status}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.image),
                              onPressed: () {
                                _showImageDialog(pot.imgPath);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _openEditModal(pot);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteData(pot.cultivationPotId, _loadData);
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
class CultivationPot {
  final int cultivationPotId;
  final int typePotId;
  final int? index; // Allow index to be nullable
  final String imgPath;
  String aiResult;
  final String status;
  String potName;

  CultivationPot({
    required this.cultivationPotId,
    required this.typePotId,
    this.index, // Allow index to be nullable
    required this.imgPath,
    required this.aiResult,
    required this.status,
    required this.potName,
  });

  factory CultivationPot.fromJson(Map<String, dynamic> json) {
    return CultivationPot(
      cultivationPotId: json['cultivation_pot_id'],
      typePotId: json['type_pot_id'],
      index: json['index'], // Allow index to be nullable
      imgPath: json['img_path'] ?? 'No data entered',
      aiResult: json['ai_result'] ?? 'No data entered',
      status: json['status'],
      potName: json['pot_name'],
    );
  }
}

class TypePot {
  final int typePotId;
  final String typePotName;

  TypePot({
    required this.typePotId,
    required this.typePotName,
  });

  factory TypePot.fromJson(Map<String, dynamic> json) {
    return TypePot(
      typePotId: json['type_pot_id'],
      typePotName: json['type_pot_name'],
    );
  }
}
