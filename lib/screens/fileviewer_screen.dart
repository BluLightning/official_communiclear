import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class FileViewerScreen extends StatefulWidget {
  final String filePath;

  const FileViewerScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  late bool isTextFile;
  String? fileContent;
  FlutterSoundPlayer? _player;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    isTextFile = widget.filePath.endsWith('.txt');
    if (isTextFile) {
      _readTextFile();
    } else {
      _initializeAudioPlayer();
    }
  }

  Future<void> _readTextFile() async {
    try {
      final file = File(widget.filePath);
      final content = await file.readAsString();
      setState(() {
        fileContent = content;
      });
    } catch (e) {
      print("Error reading file: $e");
      setState(() {
        fileContent = "Error reading file.";
      });
    }
  }

  Future<void> _initializeAudioPlayer() async {
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
  }

  Future<void> _playAudio() async {
    if (_player != null && !isPlaying) {
      await _player!.startPlayer(
        fromURI: widget.filePath,
        whenFinished: () {
          setState(() {
            isPlaying = false;
          });
        },
      );
      setState(() {
        isPlaying = true;
      });
    }
  }

  Future<void> _stopAudio() async {
    if (_player != null && isPlaying) {
      await _player!.stopPlayer();
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    _player?.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("File Viewer"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isTextFile
            ? SingleChildScrollView(
          child: Text(
            fileContent ?? "Loading...",
            style: TextStyle(fontSize: 16),
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Playing: ${widget.filePath.split('/').last}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isPlaying ? _stopAudio : _playAudio,
              child: Text(isPlaying ? "Stop Audio" : "Play Audio"),
            ),
          ],
        ),
      ),
    );
  }
}
