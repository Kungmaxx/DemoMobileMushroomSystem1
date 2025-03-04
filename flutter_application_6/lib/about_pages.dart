import 'package:flutter/material.dart';

class AboutPages extends StatelessWidget {
  const AboutPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/http_basic');
                },
                child: const Text('user page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/farm');
                },
                child: const Text('farm page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/device');
                },
                child: const Text('device page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/typepot');
                },
                child: const Text('typepot page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cultivation');
                },
                child: const Text('cultivation page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/growing');
                },
                child: const Text('growing page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cultivationpot');
                },
                child: const Text('cultivationpot page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/growingpot');
                },
                child: const Text('growingpot page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/pin');
                },
                child: const Text('pin page'),
              ),
              IconButton(
                  icon: const Icon(Icons.display_settings),
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
