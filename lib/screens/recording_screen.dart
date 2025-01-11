import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

import 'fileviewer_screen.dart'; // Ensure this is imported

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  double _playbackPosition = 0.0;
  Duration? _audioDuration;
  Stream<double>? _dbLevelStream;
  List<FileSystemEntity> _recordings = [];
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
    _loadRecordings();

    // Set up an animation controller for fallback UI feedback
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.1,
      upperBound: 1.0,
    )..repeat(reverse: true); // Oscillates the bar height
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();

    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      return;
    }

    await _recorder!.openRecorder();
    await _prepareNewRecordingPath();
  }

  Future<void> _initializePlayer() async {
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();

    _player!.onProgress!.listen((event) {
      if (_player!.isPlaying) {
        setState(() {
          _playbackPosition = event.position.inMilliseconds / event.duration.inMilliseconds;
          _audioDuration = event.duration;
        });
      }
    });
  }

  Future<void> _prepareNewRecordingPath() async {
    Directory downloadsDir = Directory('/storage/emulated/0/Download');

    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }

    _filePath = '${downloadsDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    print("Recording path set to: $_filePath");
  }

  Future<void> _startRecording() async {
    if (_recorder != null && !_isRecording) {
      setState(() => _isRecording = true);

      await _recorder!.startRecorder(
        toFile: _filePath,
        codec: Codec.pcm16WAV,
      );

      _dbLevelStream = _recorder!.onProgress!.map((event) {
        print("Decibel level: ${event.decibels}"); // Debugging log
        return event.decibels ?? 0.0;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_recorder != null && _isRecording) {
      await _recorder!.stopRecorder();
      setState(() => _isRecording = false);

      _loadRecordings();
      await _prepareNewRecordingPath();
    }
  }

  Future<void> _startPlayback(String filePath) async {
    if (_player != null && !_isPlaying && File(filePath).existsSync()) {
      setState(() {
        _isPlaying = true;
        _playbackPosition = 0.0;
      });
      await _player!.startPlayer(
        fromURI: filePath,
        codec: Codec.pcm16WAV,
        whenFinished: () {
          setState(() => _isPlaying = false);
        },
      );
    }
  }

  Future<void> _stopPlayback() async {
    if (_player != null && _isPlaying) {
      await _player!.stopPlayer();
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _loadRecordings() async {
    Directory downloadsDir = Directory('/storage/emulated/0/Download');

    if (downloadsDir.existsSync()) {
      setState(() {
        _recordings = downloadsDir
            .listSync()
            .where((file) => file.path.endsWith('.wav'))
            .toList();
      });
      print("Audio recordings loaded: ${_recordings.map((e) => e.path).toList()}");
    } else {
      print("Downloads directory does not exist.");
      setState(() {
        _recordings = [];
      });
    }
  }

  Widget _buildAudioVisualizer() {
    return StreamBuilder<double>(
      stream: _dbLevelStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return ScaleTransition(
            scale: _animationController!,
            child: Container(width: 10, height: 100, color: Colors.blue),
          );
        }

        double dbLevel = snapshot.data!;
        double normalizedLevel = max(0.1, (dbLevel + 60) / 60);

        return Container(
          width: 10,
          height: 100 * normalizedLevel,
          color: Colors.blue,
        );
      },
    );
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player!.closePlayer();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Conversation', style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              _isRecording ? "Recording in progress..." : "Press to start recording",
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              iconSize: 80,
              color: Colors.red,
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),
            if (_isRecording) ...[
              SizedBox(height: 20),
              _buildAudioVisualizer(),
            ],
            Divider(height: 40, color: Colors.white),
            Expanded(
              child: ListView.builder(
                itemCount: _recordings.length,
                itemBuilder: (context, index) {
                  FileSystemEntity recording = _recordings[index];
                  String fileName = recording.path.split('/').last;

                  return ListTile(
                    title: Text(
                      fileName,
                      style: TextStyle(fontSize: 18, color: Colors.lightBlueAccent),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.play_arrow, color: Colors.green),
                          onPressed: () => _startPlayback(recording.path),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            File(recording.path).deleteSync();
                            _loadRecordings();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
