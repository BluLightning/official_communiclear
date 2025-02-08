import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


import '../constants/color_constants.dart';

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
  bool isProcessing = false;
  List<Map<String, dynamic>> highlights = []; // For storing highlight metadata

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

  Future<void> _analyzeText() async {
    if (fileContent == null || fileContent!.isEmpty) return;

    setState(() => isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content": """
Highlight text errors and categorize them. Return JSON in the format:
[
    {"text": "example text", "color": "red", "feedback": "Grammar issue. Consider revising."},
    {"text": "another text", "color": "yellow", "feedback": "Filler word."}
]
"""
            },
            {
              "role": "user",
              "content": fileContent,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawFeedback = data['choices'][0]['message']['content'] ?? "";

        final jsonFeedback = _extractJson(rawFeedback);

        try {
          final parsedHighlights = json.decode(jsonFeedback) as List<dynamic>;
          setState(() {
            highlights = parsedHighlights.map((item) {
              return {
                "text": item["text"],
                "color": _mapColor(item["color"]),
                "feedback": item["feedback"],
              };
            }).toList();
          });
          print("Parsed Highlights: $highlights"); // Debug output
        } catch (e) {
          print("Error parsing JSON feedback: $e");
          setState(() {
            highlights = [];
          });
        }
      } else {
        print("Error analyzing text: ${response.body}");
        setState(() => highlights = []);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => highlights = []);
    }

    setState(() => isProcessing = false);
  }



  String _extractJson(String rawFeedback) {
    final jsonStart = rawFeedback.indexOf('[');
    final jsonEnd = rawFeedback.lastIndexOf(']');
    if (jsonStart != -1 && jsonEnd != -1) {
      return rawFeedback.substring(jsonStart, jsonEnd + 1);
    }
    throw FormatException("No valid JSON array found in the response.");
  }

  Color _mapColor(String color) {
    switch (color.toLowerCase()) {
      case "red":
        return Colors.red;
      case "blue":
        return Colors.blue;
      case "yellow":
        return Colors.yellow;
      default:
        return Colors.black;
    }
  }

  Widget _buildHighlightedText() {
    if (highlights.isEmpty) {
      return Text(
        fileContent ?? "No content available.",
        style: TextStyle(fontSize: 16),
      );
    }

    return RichText(
      text: TextSpan(
        children: highlights.map((highlight) {
          return TextSpan(
            text: highlight["text"],
            style: TextStyle(
              fontSize: 16,
              color: highlight["color"],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _deleteFile() async {
    try {
      final file = File(widget.filePath);
      print("Attempting to delete: ${file.path}");

      if (file.existsSync()) {
        await file.delete(); // Ensure async deletion
        print("File successfully deleted: ${file.path}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File deleted successfully.")),
        );

        Navigator.pop(context, true); // Notify parent screen about deletion
      } else {
        print("File does not exist: ${file.path}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File does not exist.")),
        );
      }
    } catch (e) {
      print("Error deleting file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting file: ${e.toString()}")),
      );
    }
  }


  Future<String> _fetchDetailedFeedback(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content": """
You are an advanced writing assistant. Provide a detailed and constructive feedback for the following text. Include specific suggestions on grammar, clarity, style, and overall improvements.
"""
            },
            {
              "role": "user",
              "content": text,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'] ?? "No feedback available.";
      } else {
        print("Error fetching detailed feedback: ${response.body}");
        return "Failed to fetch feedback. Please try again later.";
      }
    } catch (e) {
      print("Error: $e");
      return "An error occurred while fetching feedback.";
    }
  }





  Future<void> _transcribeAudio() async {
    setState(() => isProcessing = true);

    try {
      final bytes = await File(widget.filePath).readAsBytes();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer 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';
      request.fields['model'] = 'whisper-1'; // Add model parameter
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'audio.wav',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final transcription = data['text'] ?? "No transcription available.";

        // Save transcription in the same directory as the original file
        final savedPath = await _saveTranscriptionToSameDirectory(transcription, widget.filePath);

        setState(() {
          fileContent = transcription;
        });

        // Show success prompt with file path
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transcription saved at $savedPath")),
        );

        // Analyze the transcribed text
        await _analyzeText();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to transcribe audio: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error transcribing audio.")),
      );
    }

    setState(() => isProcessing = false);
  }


  Future<String> _saveTranscriptionToSameDirectory(String transcription, String originalFilePath) async {
    try {
      // Retrieve the Downloads directory explicitly
      final downloadsDir = Directory('/storage/emulated/0/Download');

      // Ensure the directory exists
      if (!downloadsDir.existsSync()) {
        throw Exception("Downloads directory does not exist.");
      }

      // Create a unique filename for the transcription
      final transcriptionFilePath = '${downloadsDir.path}/transcription_${DateTime.now().millisecondsSinceEpoch}.txt';

      // Save the transcription
      final transcriptionFile = File(transcriptionFilePath);
      await transcriptionFile.writeAsString(transcription);

      return transcriptionFilePath;
    } catch (e) {
      print("Error saving transcription: $e");
      throw Exception("Failed to save transcription to Downloads folder.");
    }
  }


  @override
  void dispose() {
    _player?.closePlayer();
    super.dispose();
  }

  Widget _buildChatBubbles() {
    if (highlights.isEmpty) {
      return Text(
        fileContent ?? "No content available.",
        style: TextStyle(fontSize: 16),
      );
    }

    return ListView.builder(
      itemCount: highlights.length,
      itemBuilder: (context, index) {
        final highlight = highlights[index];
        return GestureDetector(
          onTap: () async {
            print("Tapped Highlight: ${highlight}"); // Debug log

            // Fetch detailed feedback
            final detailedFeedback = await _fetchDetailedFeedback(highlight["text"]);

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Detailed Feedback"),
                  content: SingleChildScrollView(
                    child: Text(
                      detailedFeedback,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Close"),
                    ),
                  ],
                );
              },
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  highlight["text"],
                  style: TextStyle(
                    fontSize: 16,
                    color: highlight["color"],
                  ),
                ),
              ),
              if (highlight["feedback"] != null && highlight["feedback"]!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    highlight["feedback"],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.backgroundColor,
      appBar: AppBar(
        title: Text("File Viewer", style: GoogleFonts.robotoCondensed(
            color: ColorConst.iconColor,
            fontSize: 30)),
        backgroundColor: ColorConst.backgroundColor,
        iconTheme: IconThemeData(
          color: ColorConst.iconColor,),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Delete File"),
                    content: Text("Are you sure you want to delete this file?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Delete"),
                      ),
                    ],
                  );
                },
              );

              if (confirmDelete == true) {
                await _deleteFile();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isTextFile
            ? SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(
                child: highlights.isEmpty
                    ? Center(child: Text(fileContent ?? "No content available."))
                    : _buildChatBubbles(),
              ),
              if (isProcessing) CircularProgressIndicator(),
              if (!isProcessing)
                ElevatedButton(
                  onPressed: _analyzeText,
                  child: Text("Analyze Text"),
                ),
            ],
          ),
        )
            : SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Playing: ${widget.filePath
                    .split('/')
                    .last}",
                style: GoogleFonts.robotoCondensed(fontSize: 18, fontWeight: FontWeight.bold, color: ColorConst.primaryColor),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(ColorConst.primaryColor),
                ),
                onPressed: isPlaying ? _stopAudio : _playAudio,
                child: Text(isPlaying ? "Stop Audio" : "Play Audio", style: GoogleFonts.robotoCondensed(
                    color: ColorConst.secondaryColor
                )),
              ),
              SizedBox(height: 20),
              if (isProcessing) CircularProgressIndicator(),
              if (!isProcessing)
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(ColorConst.primaryColor),
                  ),
                  onPressed: _transcribeAudio,
                  child: Text("Transcribe and Analyze Audio", style: GoogleFonts.robotoCondensed(
                      color: ColorConst.secondaryColor
                  )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}