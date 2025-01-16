import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:official_communiclear/constants/color_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PracticeScreen extends StatefulWidget {
  final String topic;

  const PracticeScreen({super.key, required this.topic});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final String _apiKey = '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';

  @override
  void initState() {
    super.initState();
    _addIntroMessage(widget.topic);
  }

  void _addIntroMessage(String topic) {
    String introMessage;
    switch (topic) {
      case 'Job Interviews':
        introMessage = "Thank you for applying to our company. This will be a mock interview. I will ask questions, and you can respond as if it were a real interview. Let's start: What are some things that make you qualified to work here?";
        break;
      case 'Casual Conversations':
        introMessage = "Hi there! How was your day? Let’s practice casual conversation. Feel free to ask me questions too!";
        break;
      case 'Public Speaking':
        introMessage = "Imagine you’re presenting to a large audience. Start by introducing yourself and your topic. I'll provide feedback and simulate audience questions.";
        break;
      default:
        introMessage = "Let’s practice improving your communication skills on the topic: $topic. I will engage with you in a conversational format.";
    }
    setState(() {
      _messages.add({"sender": "ai", "message": introMessage});
    });
  }

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
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content": "You are a chatbot designed to simulate realistic, ongoing conversations to help improve communication skills. For the topic '${widget.topic}', engage in a natural back-and-forth dialogue. Avoid giving feedback unless explicitly asked. Continue the conversation naturally and respond to the user's input appropriately."
          },
          ..._messages.map((msg) => {
            "role": msg['sender'] == "user" ? "user" : "assistant",
            "content": msg['message']
          }),
          {"role": "user", "content": message},
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

  Future<void> _provideFeedback() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content": "Provide a summary and detailed feedback for the conversation, focusing on areas of improvement in communication skills such as clarity, tone, grammar, and suggestions for better responses."
          },
          ..._messages.map((msg) => {
            "role": msg['sender'] == "user" ? "user" : "assistant",
            "content": msg['message']
          })
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final feedback = data['choices'][0]['message']['content'];

      setState(() {
        _messages.add({"sender": "ai", "message": feedback});
        _isLoading = false;
      });
    } else {
      setState(() {
        _messages.add({"sender": "ai", "message": "Error: Unable to fetch feedback."});
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

      // Use the Download directory for saving the file
      final directory = Directory('/storage/emulated/0/Download'); // Path to the public Download folder
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Define the file path
      final filePath =
          '${directory.path}/conversation_${DateTime.now().millisecondsSinceEpoch}.txt';

      // Save the conversation to the file
      final file = File(filePath);
      await file.writeAsString(conversation);

      // Notify the user of success
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
  Future<List<Map<String, String>>> analyzeSentenceWithContext(
      String newMessage,
      List<Map<String, String>> conversationContext) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    // Build the message list for the API call, including context
    final List<Map<String, String>> apiMessages = [
      {
        "role": "system",
        "content": "You are a language analysis tool. Break down the most recent user message into individual words or phrases and provide feedback in the following JSON format:\n\n{\n  {\"word\": \"<word>\", \"color\": \"<color>\", \"explanation\": \"<reason for the color>\"},\n  ...\n}\n\nUse the colors 'green' (correct), 'yellow' (partially correct or unclear), and 'red' (incorrect or problematic). Ensure the output is structured as valid JSON for processing. Consider the conversation context provided for better accuracy."
      },
      // Include the conversation context
      ...conversationContext.map((msg) => {
        "role": msg['sender'] == "user" ? "user" : "assistant",
        "content": msg['message']!
      }),
      // Add the new message for analysis
      {"role": "user", "content": newMessage},
    ];

    // Send the API request
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "model": "gpt-3.5-turbo",
        "messages": apiMessages,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final aiResponse = data['choices'][0]['message']['content'];

      try {
        // Parse the structured JSON response
        print(aiResponse);
        return List<Map<String, String>>.from(json.decode(aiResponse));
      } catch (e) {
        print("Error parsing AI response: $e");
        return [];
      }
    } else {
      print("Error: ${response.statusCode}");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Practice Bot",
          style: GoogleFonts.robotoCondensed(
            color: ColorConst.backgroundColor,
            fontSize: 30,
          ),
        ),
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
                          ? BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      )
                          : BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
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
                    style: TextStyle(color: ColorConst.primaryColor),
                    cursorColor: ColorConst.primaryColor,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: TextStyle(color: ColorConst.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: ColorConst.primaryColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: ColorConst.iconColor,
                  ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _provideFeedback,
                    child: Text("End Conversation & Get Feedback"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveConversation,
                    child: Text("Save Conversation"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
