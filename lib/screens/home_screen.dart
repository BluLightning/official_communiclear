import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/color_constants.dart';
import 'recording_screen.dart'; // Import the RecordingScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                color: Colors.blue,
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
                            ? ((MediaQuery.of(context).size.width - 40) / 3) - 60
                            : ((MediaQuery.of(context).size.width - 40) / 3) - 160,
                        height: MediaQuery.of(context).size.width < 500
                            ? ((MediaQuery.of(context).size.width - 40) / 3) - 60
                            : ((MediaQuery.of(context).size.width - 40) / 3) - 160,
                        child: IconButton(
                          onPressed: () {},
                          icon: Image(
                            image: AssetImage('assets/microphone.png'),
                            height: MediaQuery.of(context).size.width < 500 ? 40 : 120,
                            width: MediaQuery.of(context).size.width < 500 ? 40 : 120,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Upload",
                        style: GoogleFonts.robotoCondensed(
                          color: Colors.white,
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
                            ? ((MediaQuery.of(context).size.width - 40) / 3) - 60
                            : ((MediaQuery.of(context).size.width - 40) / 3) - 160,
                        height: MediaQuery.of(context).size.width < 500
                            ? ((MediaQuery.of(context).size.width - 40) / 3) - 60
                            : ((MediaQuery.of(context).size.width - 40) / 3) - 160,
                        child: IconButton(
                          onPressed: () {},
                          icon: Image(
                            image: AssetImage('assets/upload.png'),
                            height: MediaQuery.of(context).size.width < 500 ? 40 : 120,
                            width: MediaQuery.of(context).size.width < 500 ? 40 : 120,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Practice",
                        style: GoogleFonts.robotoCondensed(
                          color: Colors.white,
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
                            ? ((MediaQuery.of(context).size.width - 40) / 3) - 60
                            : ((MediaQuery.of(context).size.width - 40) / 3) - 160,
                        height: MediaQuery.of(context).size.width < 500
                            ? ((MediaQuery.of(context).size.width - 40) / 3) - 60
                            : ((MediaQuery.of(context).size.width - 40) / 3) - 160,
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
                            image: AssetImage('assets/chat.png'),
                            height: MediaQuery.of(context).size.width < 500 ? 40 : 120,
                            width: MediaQuery.of(context).size.width < 500 ? 40 : 120,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Record",
                        style: GoogleFonts.robotoCondensed(
                          color: Colors.white,
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
                        color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(
                    width: 125,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "History",
                            style: GoogleFonts.robotoCondensed(
                                color: Colors.white, fontSize: 20),
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
                color: Colors.blue,
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
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("Created on December 24, 2024"),
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
