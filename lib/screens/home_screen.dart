import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:official_communiclear/screens/practice_screen.dart';
import '../constants/color_constants.dart';
import 'recording_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'fileviewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> soundOpener() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'mp4', 'wav', 'txt'],
    );

    if (result != null) {
      File pickedFile = File(result.files.single.path!);
      print("Picked file: ${pickedFile.path}");

      if (pickedFile.existsSync()) {
        final isDeleted = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FileViewerScreen(filePath: pickedFile.path),
          ),
        );

        // Refresh UI after a file is deleted
        if (isDeleted == true) {
          setState(() {});
        }
      } else {
        print("File does not exist anymore.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File not found. It may have been deleted.")),
        );
      }
    } else {
      print("User canceled the picker.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorConst.backgroundColor,
        title: Text(
          "Home",
          style: GoogleFonts.robotoCondensed(
            color: ColorConst.iconColor,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 20),

          Center(
            child: Image.asset(
              'assets/Logo.jpg', // Add your app logo here
              height: 150,
            ),
          ),

          // Three Primary Buttons (Now Moved to the Bottom)
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton("Practice", "assets/chat.png", () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return _buildPracticeModal();
                    },
                  );
                }),
                _buildButton("Upload", "assets/upload.png", soundOpener),
                _buildButton("Record", "assets/microphone.png", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordingScreen(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the Practice, Upload, and Record Buttons
  Widget _buildButton(String title, String assetPath, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          width: 80,
          height: 80,
          child: IconButton(
            onPressed: onTap,
            icon: Image.asset(
              assetPath,
              height: 40,
              width: 40,
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          title,
          style: GoogleFonts.robotoCondensed(
            color: ColorConst.primaryColor,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // Function to build Practice Modal
  Widget _buildPracticeModal() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
        color: ColorConst.backgroundColor,
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Choose Conversation Topic",
            style: TextStyle(color: ColorConst.primaryColor),
          ),
          SizedBox(height: 20),
          _buildPracticeOption('Job Interviews'),
          _buildPracticeOption('Casual Conversations'),
          _buildPracticeOption('Public Speaking'),
        ],
      ),
    );
  }

  // Function to build Practice Options
  Widget _buildPracticeOption(String topic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 40,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PracticeScreen(topic: topic),
              ),
            );
          },
          child: Text(topic),
        ),
      ),
    );
  }
}
