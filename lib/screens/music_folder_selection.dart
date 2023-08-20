import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:musix/screens/music_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicFolderSelection extends StatefulWidget {
  const MusicFolderSelection({super.key});

  @override
  State<MusicFolderSelection> createState() => _MusicFolderSelectionState();
}

class _MusicFolderSelectionState extends State<MusicFolderSelection> {
  final String musicPathKey = 'music_path';
  String _musicPath = '';

  @override
  void initState() {
    super.initState();
    _getMusicPath();
  }

  Future<void> _chooseMusicPath(BuildContext context) async {
    String? selectedPath = await FilesystemPicker.open(
          title: 'Choose a folder',
          context: context,
          rootDirectory: Directory('/storage/emulated/0/'),
          fsType: FilesystemType.folder,
          pickText: 'Read musics from this folder',
        ) ??
        '';
    await [Permission.audio].request();
    PermissionStatus status = await Permission.audio.status;
    if (selectedPath.isNotEmpty && status.isGranted) {
      await _setMusicPath(selectedPath);
    }
  }

  Future<void> _getMusicPath() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      _musicPath = (preferences.getString(musicPathKey) ?? '');
    });
  }

  Future<void> _setMusicPath(String selectedPath) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(musicPathKey, selectedPath);
    await _getMusicPath();
  }

  @override
  Widget build(BuildContext context) {
    if (_musicPath.isNotEmpty) {
      return MusicList(
        musicPath: _musicPath,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(),
        Text(_musicPath.isEmpty
            ? 'No music folder selected'
            : 'Selected music folder is:\n\n$_musicPath'),
        FilledButton(
            onPressed: () => _chooseMusicPath(context),
            child: const Text('Choose Folder')),
      ]),
    );
  }
}
