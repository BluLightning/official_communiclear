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
    Directory appDocDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> recordings = appDocDir
        .listSync()
        .where((file) => file.path.endsWith('.wav'))
        .toList();

    if (recordings.isNotEmpty) {
      print("Recordings available in the app's directory:");
      for (var recording in recordings) {
        print("Recording: ${recording.path}");
      }
    } else {
      print("No recordings found in the app's directory.");
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'mp4', 'wav', 'txt'],
    );

    if (result != null) {
      File pickedFile = File(result.files.single.path!);
      print("Picked file: ${pickedFile.path}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileViewerScreen(filePath: pickedFile.path),
        ),
      );
    } else {
      print("User canceled the picker.");
    }
  }

  void _playAudio(File audioFile) {
    print("Playing audio file: ${audioFile.path}");
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
            color: Colors.blue,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: ColorConst.containerColor,
                borderRadius: BorderRadius.circular(20),
              ),
              width: MediaQuery.of(context).size.width - 40,
              height: MediaQuery.of(context).size.width < 500 ? 120 : 350,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: MediaQuery.of(context).size.width < 500
                            ? ((MediaQuery.of(context).size.width - 40) / 3) -
                            60
                            : ((MediaQuery.of(context).size.width - 40) / 3) -
                            160,
                        height: MediaQuery.of(context).size.width < 500
                            ? ((MediaQuery.of(context).size.width - 40) / 3) -
                            60
                            : ((MediaQuery.of(context).size.width - 40) / 3) -
                            160,
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  height:
                                  MediaQuery.of(context).size.height / 2,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(25),
                                          topLeft: Radius.circular(25)),
                                      color: ColorConst.backgroundColor),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "Choose Conversation Topic",
                                          style: TextStyle(
                                              color: ColorConst.primaryColor),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width:
                                          MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PracticeScreen(
                                                        topic: 'Job Interviews',
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Text('Job Interviews'),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width:
                                          MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PracticeScreen(
                                                        topic: 'Casual Conversations',
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Text('Casual Conversations'),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width:
                                          MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PracticeScreen(
                                                        topic: 'Public Speaking',
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Text('Public Speaking'),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: Image(
                            image: AssetImage('assets/chat.png'),
                            height: MediaQuery.of(context).size.width < 500
                                ? 40
                                : 120,
                            width: MediaQuery.of(context).size.width < 500
                                ? 40
                                : 120,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Practice",
                        style: GoogleFonts.robotoCondensed(
                          color: ColorConst.primaryColor,
                          fontSize: 18,
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: MediaQuery.of(context).size.width < 500
                            ? ((MediaQuery.of(context).size.width - 40) / 3) -
                            60
                            : ((MediaQuery.of(context).size.width - 40) / 3) -
                            160,
                        height: MediaQuery.of(context).size.width < 500
                            ? ((MediaQuery.of(context).size.width - 40) / 3) -
                            60
                            : ((MediaQuery.of(context).size.width - 40) / 3) -
                            160,
                        child: IconButton(
                          onPressed: () async {
                            await soundOpener();
                          },
                          icon: Image(
                            image: AssetImage('assets/upload.png'),
                            height: MediaQuery.of(context).size.width < 500
                                ? 40
                                : 120,
                            width: MediaQuery.of(context).size.width < 500
                                ? 40
                                : 120,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Upload",
                        style: GoogleFonts.robotoCondensed(
                          color: ColorConst.primaryColor,
                          fontSize: 18,
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: MediaQuery.of(context).size.width < 500
                            ? ((MediaQuery.of(context).size.width - 40) / 3) -
                            60
                            : ((MediaQuery.of(context).size.width - 40) / 3) -
                            160,
                        height: MediaQuery.of(context).size.width < 500
                            ? ((MediaQuery.of(context).size.width - 40) / 3) -
                            60
                            : ((MediaQuery.of(context).size.width - 40) / 3) -
                            160,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RecordingScreen(),
                              ),
                            );
                          },
                          icon: Image(
                            image: AssetImage('assets/microphone.png'),
                            height: MediaQuery.of(context).size.width < 500
                                ? 40
                                : 120,
                            width: MediaQuery.of(context).size.width < 500
                                ? 40
                                : 120,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Record",
                        style: GoogleFonts.robotoCondensed(
                          color: ColorConst.primaryColor,
                          fontSize: 18,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey.shade800),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent",
                    style: GoogleFonts.robotoCondensed(
                        color: ColorConst.primaryColor, fontSize: 20),
                  ),
                  SizedBox(
                    width: 125,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              ColorConst.containerColor),
                          padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          )),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "History",
                            style: GoogleFonts.robotoCondensed(
                                color: ColorConst.primaryColor, fontSize: 20),
                          ),
                          Icon(
                            CupertinoIcons.arrow_right_circle,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: ColorConst.containerColor,
                borderRadius: BorderRadius.circular(20),
              ),
              width: MediaQuery.of(context).size.width - 40,
              height: MediaQuery.of(context).size.width < 500 ? 120 : 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Text that is coming from the audio why didn't it work this computer is broken",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.robotoCondensed(
                            color: ColorConst.primaryColor),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Created on December 24, 2024",
                        style: GoogleFonts.robotoCondensed(
                            color: ColorConst.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
