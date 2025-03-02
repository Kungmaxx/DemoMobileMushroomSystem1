import 'package:flutter/material.dart';
import 'display_page.dart';
import 'welcome_page2.dart';
import 'my_futurebuilder_page.dart';
import 'http_basic.dart';

class AboutPages extends StatelessWidget {
  const AboutPages({super.key});

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
                Navigator.pushNamed(context, '/display_page');
                debugPrint("ElevatedButton in AppBar pressed");
              },
              child: const Text('Display!'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Info",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Image.network(
                  "https://cdn.grange.co.uk/assets/new-cars/lamborghini/revuelto/revuelto-1_20241107093150469.png",
                  height: 150,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/welcome_page2');
                },
                child: const Text('Welcome page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/display_page');
                },
                child: const Text('Display page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/my_futurebuilder_page');
                },
                child: const Text('Futurebuilder page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/http_basic');
                },
                child: const Text('Http Basic page'),
              ),
              IconButton(
                  icon: Icon(Icons.display_settings),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/display_page',
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
