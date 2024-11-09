import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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
    Directory tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  Future<void> _startRecording() async {
    if (_recorder != null && !_isRecording) {
      setState(() => _isRecording = true);

      await _recorder!.startRecorder(
        toFile: _filePath,
        codec: Codec.pcm16WAV,
      );

      // Start listening to the dB level if available
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

      // Refresh the recording history
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
    Directory tempDir = await getTemporaryDirectory();
    setState(() {
      _recordings = tempDir.listSync().where((file) => file.path.endsWith('.wav')).toList();
    });
  }

  Future<void> _renameRecording(FileSystemEntity recording) async {
    String oldPath = recording.path;
    String newName = await _showRenameDialog(recording.path.split('/').last);
    if (newName.isNotEmpty) {
      Directory dir = recording.parent;
      String newPath = '${dir.path}/$newName.wav';
      await recording.rename(newPath);
      _loadRecordings();
    }
  }

  Future<String> _showRenameDialog(String currentName) async {
    TextEditingController controller = TextEditingController(text: currentName.replaceAll('.wav', ''));
    String newName = '';

    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rename Recording"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "New name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                newName = controller.text;
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
    return newName;
  }

  Widget _buildAudioVisualizer() {
    return StreamBuilder<double>(
      stream: _dbLevelStream,
      builder: (context, snapshot) {
        // If dB level is not provided, fall back to oscillating animation
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return ScaleTransition(
            scale: _animationController!,
            child: Container(width: 10, height: 100, color: Colors.blue),
          );
        }

        // Use actual dB level if available
        double dbLevel = snapshot.data!;
        double normalizedLevel = max(0.1, (dbLevel + 60) / 60); // Normalize to a range of 0.1 to 1.0

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
        title: Text('Record Conversation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
              _buildAudioVisualizer(),
            ],
            Divider(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: _recordings.length,
                itemBuilder: (context, index) {
                  FileSystemEntity recording = _recordings[index];
                  String fileName = recording.path.split('/').last;

                  return ListTile(
                    title: GestureDetector(
                      onTap: () => _renameRecording(recording),
                      child: Text(fileName),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () => _startPlayback(recording.path),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            recording.deleteSync();
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
    );
  }
}
