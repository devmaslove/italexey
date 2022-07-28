import 'package:directus/directus.dart';
import 'package:flutter/material.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  Directus? sdk;

  void initDirectus() async {
    final files = await DirectusSingleton.instance.files.readMany();
    print(files.data.first.filenameDownload);
  }

  @override
  void initState() {
    super.initState();
    initDirectus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Файлы')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Тут будут файлы'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Загрузить файл',
        child: const Icon(Icons.upload),
      ),
    );
  }
}
