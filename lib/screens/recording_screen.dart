import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  double _playbackPosition = 0.0;
  Duration? _audioDuration;
  Stream<double>? _dbLevelStream;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();

    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      // Handle permission denied
      return;
    }

    await _recorder!.openRecorder();

    // Set up file path in the temporary directory
    Directory tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/recorded_audio.aac';
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

  Future<void> _startRecording() async {
    if (_recorder != null && !_isRecording) {
      setState(() => _isRecording = true);

      // Start recording and enable dB monitoring
      await _recorder!.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
      );

      // Start listening to the dB level
      _dbLevelStream = _recorder!.onProgress!.map((event) => event.decibels ?? 0.0);
    }
  }

  Future<void> _stopRecording() async {
    if (_recorder != null && _isRecording) {
      await _recorder!.stopRecorder();
      setState(() => _isRecording = false);
    }
  }

  Future<void> _startPlayback() async {
    if (_player != null && !_isPlaying && _filePath != null && File(_filePath!).existsSync()) {
      setState(() {
        _isPlaying = true;
        _playbackPosition = 0.0; // Reset the playback position
      });
      await _player!.startPlayer(
        fromURI: _filePath,
        codec: Codec.aacADTS,
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

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player!.closePlayer();
    super.dispose();
  }

  Widget _buildAudioVisualizer() {
    return StreamBuilder<double>(
      stream: _dbLevelStream,
      builder: (context, snapshot) {
        double dbLevel = snapshot.data ?? 0.0;
        double normalizedLevel = (dbLevel + 60) / 60; // Normalize dB level to 0-1
        return Container(
          width: 10,
          height: 100 * normalizedLevel,
          color: Colors.blue,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Conversation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isRecording ? "Recording in progress..." : "Press to start recording",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              iconSize: 80,
              color: Colors.blue,
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),
            if (_isRecording) ...[
              SizedBox(height: 20),
              _buildAudioVisualizer(), // Display the visualizer when recording
            ],
            if (!_isRecording)
              Column(
                children: [
                  Slider(
                    value: _playbackPosition,
                    onChanged: (value) {
                      if (_player!.isPlaying && _audioDuration != null) {
                        setState(() {
                          _playbackPosition = value;
                          _player!.seekToPlayer(Duration(milliseconds: (value * _audioDuration!.inMilliseconds).toInt()));
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    iconSize: 80,
                    color: Colors.green,
                    onPressed: _isPlaying ? _stopPlayback : _startPlayback,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
