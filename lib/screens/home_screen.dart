import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              width: MediaQuery.of(context).size.width - 40,
              height: 120,
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
                        width:
                            ((MediaQuery.of(context).size.width - 40) / 3) - 60,
                        height:
                            ((MediaQuery.of(context).size.width - 40) / 3) - 60,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(CupertinoIcons.mic_fill, size: 30, color: Colors.red,),
                        ),
                      ),
                      Text("Record", style: GoogleFonts.robotoCondensed(
                        color: Colors.white,
                        fontSize: 18,
                      ),)
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
                        width:
                        ((MediaQuery.of(context).size.width - 40) / 3) - 60,
                        height:
                        ((MediaQuery.of(context).size.width - 40) / 3) - 60,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(CupertinoIcons.mic, size: 30, color: Colors.red,),
                        ),
                      ),
                      Text("Record", style: GoogleFonts.robotoCondensed(
                        color: Colors.white,
                        fontSize: 18,
                      ),)
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
                        width:
                        ((MediaQuery.of(context).size.width - 40) / 3) - 60,
                        height:
                        ((MediaQuery.of(context).size.width - 40) / 3) - 60,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(CupertinoIcons.mic, size: 30, color: Colors.red,),
                        ),
                      ),
                      Text("Record", style: GoogleFonts.robotoCondensed(
                        color: Colors.white,
                        fontSize: 18,
                      ),)
                    ],
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

// Strings => "This is a string"
// Bool or Booleans => true or false
// Integers => whole numbers
// Doubles => decimal number but big (takes a lot of number)
// Floats => decimal number but small (takes less numbers)
