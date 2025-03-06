import 'package:flutter/material.dart';
import 'package:flutter_application_6/about_pages.dart';
import 'package:flutter_application_6/user.dart';
import 'package:flutter_application_6/farm.dart';
import 'package:flutter_application_6/device.dart';
import 'package:flutter_application_6/typepot.dart';
import 'package:flutter_application_6/cultivation.dart';
import 'package:flutter_application_6/growing.dart';
import 'package:flutter_application_6/cultivationpot.dart';
import 'package:flutter_application_6/growingpot.dart';
import 'package:flutter_application_6/pin.dart';
import 'package:flutter_application_6/custom_scaffold.dart';

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
            const AppBarTheme(color: Color.fromARGB(255, 179, 179, 179)),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 179, 179, 179)),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        '/about_pages': (context) => const CustomScaffold(
              body: AboutPages(),
              title: 'Route Page Example',
            ),
        '/http_basic': (context) => const CustomScaffold(
              body: UserPage(),
              title: 'User Page',
            ),
        '/farm': (context) => const CustomScaffold(
              body: FarmPage(),
              title: 'Farm Page',
            ),
        '/device': (context) => const CustomScaffold(
              body: DevicePage(),
              title: 'Device Page',
            ),
        '/typepot': (context) => const CustomScaffold(
              body: TypepotPage(),
              title: 'Typepot Page',
            ),
        '/cultivation': (context) => const CustomScaffold(
              body: CultivationPage(),
              title: 'Cultivation Page',
            ),
        '/growing': (context) => const CustomScaffold(
              body: GrowingPage(),
              title: 'Growing Page',
            ),
        '/cultivationpot': (context) => const CustomScaffold(
              body: CultivationpotPage(
                cultivationId: 0,
              ),
              title: 'Cultivationpot Page',
            ),
        '/growingpot': (context) => const CustomScaffold(
              body: GrowingpotPage(
                growingId: 0,
              ),
              title: 'Growingpot Page',
            ),
        '/pin': (context) => const PinPage(), // No navigation drawer
      },
      home: const CustomScaffold(
        body: AboutPages(),
        title: 'Route Page Example',
      ),
    );
  }
}
