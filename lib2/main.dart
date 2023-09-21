// ignore_for_file: avoid_print

import 'package:flowcid/dbhelper/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:flowcid/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await MongoDatabase.connect();
    runApp(const MyApp());
  } catch (e) {
    print('Error during app initialization: $e');
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
