import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'journal.dart';

class PromptPage extends StatefulWidget {
  @override
  _PromptPageState createState() => _PromptPageState();
}

class _PromptPageState extends State<PromptPage> {
  String _currentPrompt = "";
  final List<String> prompts = [
    "Hey, Name! Let's get creative!",
    "Write a poem about a journey.",
    "Draw a picture inspired by music.",
    "Create a story with a surprising twist.",
    "Create a story with a surprising twist.",
  ];
  int currentPromptIndex = 0; // Index of the current prompt

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color(0xFF110340),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your prompt:',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      fontSize: 50,
                      color: const Color(0xFFFFFCF2),
                    ),
                  ),
                  const SizedBox(height: 35.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedOpacity(
                        opacity: _currentPrompt.isEmpty ? 0.0 : 1.0,
                        duration: Duration(seconds: 1),
                        child: Text(
                          prompts[currentPromptIndex],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            fontSize: 40,
                            color: const Color(0xFFFFFCF2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35.0),
                      ElevatedButton(
                        onPressed: () => _refreshPrompt(),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF472bad),
                          ),
                          overlayColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return const Color(0xFFFFB12B);
                              }
                              return const Color(0xFF472bad);
                            },
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.refresh,
                            size: 40.0,
                            color: Color(0xFFFFFCF2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100.0),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context, prompts[currentPromptIndex]);
                        },
                        icon: const Icon(
                          Icons.arrow_downward,
                          size: 50,
                          color: Color(0xFFD38BF5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshPrompt() {
    setState(() {
      _currentPrompt = ""; // Fade out old prompt
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        // Update prompt index and handle overflow
        currentPromptIndex = (currentPromptIndex + 1) % prompts.length;
        _currentPrompt = prompts[currentPromptIndex]; // Set new prompt
      });
    });
  }
}
