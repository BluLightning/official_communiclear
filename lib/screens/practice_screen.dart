import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:official_communiclear/constants/color_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Replace with your OpenAI API key
  final String _apiKey = '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';

  Future<void> _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
      _messages.add({"sender": "user", "message": message});
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "model": "gpt-3.5-turbo", // or your preferred model
        "messages": [
          {"role": "system", "content": "Take on the role of a dialect coach to help me practice my conversation skills."},
          ..._messages.map((msg) => {"role": msg['sender'] == "user" ? "user" : "assistant", "content": msg['message']}),
          {"role": "user", "content": message}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final aiMessage = data['choices'][0]['message']['content'];

      setState(() {
        _messages.add({"sender": "ai", "message": aiMessage});
        _isLoading = false;
      });
    } else {
      setState(() {
        _messages.add({"sender": "ai", "message": "Error: Unable to fetch response."});
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConversation() async {
    try {
      // Convert messages to a single string
      String conversation = _messages.map((msg) {
        final sender = msg['sender'] == 'user' ? 'You' : 'AI';
        return "$sender: ${msg['message']}";
      }).join("\n");

      // Get the public external storage directory
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Define the file path
      final filePath = '${directory.path}/conversation_${DateTime.now().millisecondsSinceEpoch}.txt';

      // Save the conversation to the file
      final file = File(filePath);
      await file.writeAsString(conversation);

      // Provide feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conversation saved to $filePath')),
      );

      print('Conversation saved: $filePath');
    } catch (e) {
      // Handle errors
      print('Error saving conversation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save conversation')),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<List<FileSystemEntity>> _listSavedConversations() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.listSync().where((file) => file.path.endsWith('.txt')).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.backgroundColor,
      appBar: AppBar(
        title: Text("Chat with AI", style: GoogleFonts.robotoCondensed(
          color: ColorConst.backgroundColor,
          fontSize: 30,
        ),),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey.shade300,
                      borderRadius: isUser
                          ? BorderRadius.only(topLeft: Radius.circular(10), bottomLeft:Radius.circular(10), topRight: Radius.circular(10),)
                          :BorderRadius.only(topLeft: Radius.circular(10), bottomRight:Radius.circular(10), topRight: Radius.circular(10),),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      _controller.clear();
                      _sendMessage(message);
                    }
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _saveConversation,
            child: Text("Save Conversation"),
          ),
        ],
      ),
    );
  }
}
