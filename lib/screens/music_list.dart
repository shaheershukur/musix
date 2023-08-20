import 'dart:io';

import 'package:flutter/material.dart';
import 'package:musix/screens/music_player.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key, required String musicPath})
      : _musicPath = musicPath;
  final String _musicPath;

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  Future<List<File>> _getSongs() async {
    return Directory(widget._musicPath)
        .listSync(recursive: true, followLinks: false)
        .where((element) => element.path.endsWith('.mp3'))
        .map((element) => element as File)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<File>>(
      future: _getSongs(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<File> songs = snapshot.data;
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Card(
                  elevation: 6,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MusicPlayer(songs: songs, songIndex: index),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note, color: Colors.teal),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(songs[index].path.substring(
                              songs[index].path.lastIndexOf('/') + 1,
                              songs[index].path.lastIndexOf('.'))),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
