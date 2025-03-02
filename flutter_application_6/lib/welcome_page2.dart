import 'package:flutter/material.dart';
import 'display_page.dart';

class WelcomePage2 extends StatefulWidget {
  const WelcomePage2({super.key});

  @override
  _WelcomePage2State createState() => _WelcomePage2State();
}

class _WelcomePage2State extends State<WelcomePage2> {
  final _textController = TextEditingController();

  String displayText = 'Charging Data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            debugPrint("Leading clicked");
          },
          icon: const Icon(Icons.ev_station),
        ),
        title: const Text(
          'CS Hello About Page',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              debugPrint("Button pressed");
            },
            icon: const Icon(Icons.add_alert),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                 Navigator.pushNamed(context, '/about_pages');
                debugPrint("ElevatedButton in AppBar pressed");
              },
              child: const Text('About Page!'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  displayText,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String input = _textController.text;
                  int inputAge = 18;
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         DisplayPage(name: input, age: inputAge),
                  //   ),
                  // );
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DisplayPage(name: input, age: inputAge),
                      ),
                      (route) => false);
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
