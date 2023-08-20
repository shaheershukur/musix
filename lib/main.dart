import 'package:flutter/material.dart';
import 'package:musix/screens/music_folder_selection.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Musix'),
        ),
        body: const MusicFolderSelection(),
      ),
    );
  }
}
