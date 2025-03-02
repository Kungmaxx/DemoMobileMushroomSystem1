import 'package:flutter/material.dart';
import 'package:flutter_application_6/about_pages.dart';
import 'package:flutter_application_6/welcome_page2.dart';
import 'package:flutter_application_6/display_page.dart';
import 'package:flutter_application_6/my_futurebuilder_page.dart';
import 'package:flutter_application_6/http_basic.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme:
            const AppBarTheme(color: Color.fromARGB(255, 186, 224, 16)),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 162, 229, 18)),
        useMaterial3: true,
      ),
      initialRoute: "/",
      // routes: {
      //   '/': (context) => WelcomePage2(),
      //   '/welcome_page2': (context) => WelcomePage2(),
      // },

      routes: {
        '/about_pages': (context) => AboutPages(),
        '/welcome_page2': (context) => WelcomePage2(),
        '/http_basic': (context) => HttpBasic(),
        '/my_futurebuilder_page': (context) => MyFutureBuilderPage(),
        '/display_page': (context) => DisplayPage(
              name: '',
            ),
      },
      home: const AboutPages(),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Page'),
      ),
      body: const Center(
        child: Text(
          'This is the About Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
