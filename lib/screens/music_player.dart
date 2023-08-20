import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

enum PlayerOption { previous, play, next }

class MusicPlayer extends StatefulWidget {
  MusicPlayer({super.key, required this.songs, required this.songIndex});
  final audioPlayer = AudioPlayer();
  final List<File> songs;
  int songIndex;

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  late File currentSong = File('');
  late String trackName = '';
  late Uint8List trackArt = Uint8List.fromList([]);
  late double? progress = 0.0;

  Future<void> _handlePlayer(PlayerOption option) async {
    switch (option) {
      case PlayerOption.previous:
        if (widget.songIndex == 0) {
          widget.songIndex = widget.songs.length - 1;
        } else {
          widget.songIndex -= 1;
        }
        break;
      case PlayerOption.next:
        if (widget.songIndex == widget.songs.length - 1) {
          widget.songIndex = 0;
        } else {
          setState(() {
            widget.songIndex += 1;
          });
        }
        break;
      default:
        if (widget.audioPlayer.state == PlayerState.playing) {
          await widget.audioPlayer.pause();
        } else {
          await widget.audioPlayer.play(DeviceFileSource(currentSong.path));
        }
    }
    setState(() {});
  }

  Future<void> _loadSongData() async {
    currentSong = widget.songs[widget.songIndex];
    final songMetadata = await MetadataRetriever.fromFile(currentSong);
    trackName = songMetadata.trackName ?? 'Track Name';
    trackArt = songMetadata.albumArt ?? Uint8List.fromList([]);
  }

  @override
  void dispose() {
    widget.audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Now Playing'),
          ),
          body: FutureBuilder(
            future: _loadSongData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const SizedBox(
                              height: 40,
                            ),
                            Image.memory(trackArt),
                            const SizedBox(
                              height: 40,
                            ),
                            Text(
                              trackName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 28),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                    onPressed: () =>
                                        _handlePlayer(PlayerOption.previous),
                                    icon: const Icon(Icons.skip_previous)),
                                IconButton(
                                    iconSize: 64,
                                    onPressed: () =>
                                        _handlePlayer(PlayerOption.play),
                                    icon: widget.audioPlayer.state ==
                                            PlayerState.playing
                                        ? const Icon(
                                            Icons.pause_circle,
                                            color: Colors.teal,
                                          )
                                        : const Icon(
                                            Icons.play_circle,
                                            color: Colors.teal,
                                          )),
                                IconButton(
                                    onPressed: () =>
                                        _handlePlayer(PlayerOption.next),
                                    icon: const Icon(Icons.skip_next)),
                              ],
                            ),
                          ],
                        )
                      ]),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ));
  }
}
