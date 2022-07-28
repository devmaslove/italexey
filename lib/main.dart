import 'package:directus/directus.dart';
import 'package:flutter/material.dart';
import 'package:italexey/pages/files_page.dart';
import 'package:italexey/resources/env.dart';

void main() async {
  await DirectusSingleton.init(AppEnv.link);
  DirectusSingleton.instance.auth.staticToken(AppEnv.token);
  //
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directus Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FilesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
