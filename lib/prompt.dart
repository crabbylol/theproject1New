import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for user authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'database_service.dart'; // Import the DatabaseService
import 'promptEntry.dart'; // Import the PromptEntry model
import 'journal.dart';

class PromptPage extends StatefulWidget {
  @override
  _PromptPageState createState() => _PromptPageState();
}

class _PromptPageState extends State<PromptPage> {
  final List<String> prompts = [
    "Hey, Name! Let's get creative!",
    "Write a poem about a journey.",
    "Draw a picture inspired by music.",
    "Create a story with a surprising twist.",
    "Create a story with a surprising twist.",
  ];
  int currentPromptIndex = 0; // Index of the current prompt
  String currentPrompt = '';

  late final model = GenerativeModel(
      apiKey: dotenv.env['OPENAI_API_KEY']!, model: 'gemini-pro');

  // Create an instance of the DatabaseService
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  Future<void> geminiFunctionCalling() async {
    print("Running analysis");

    String systemPrompt =
        "Act like a therapist and create 1 self-reflection writing prompt.Each prompt must be 1 sentence long (under 30 words).The prompts should use 7th-8th grade language.Make each prompt interesting, creative, and easy to understand to help people reflect on their daily choices.Ensure they are deeply reflective but written using clear and simple language suitable for middle school students.Base them on evidence-backed ideas (no need to explain the evidence).Avoid using complex or scientific terms.Only 1 of the 35 prompts should be about kindness.";
    String userPrompt = 'Provide me with a prompt';

    final chat = model.startChat(history: [
      Content.text(userPrompt),
      Content.model([TextPart(systemPrompt)])
    ]);

    final response = await chat.sendMessage(Content.text(userPrompt));

    print("Analysis ran, printing result:");
    currentPrompt = response.text ?? "No prompt generated."; // Ensure a fallback value
    print("Result printed: $currentPrompt");

    if (!mounted) return;

    // Update the UI state with the generated prompt
    setState(() {
      currentPrompt = currentPrompt;
    });

    // Record the prompt in Firestore after it is set
    await recordPromptEntry();
  }

  // Method to record the prompt entry in Firestore
  Future<void> recordPromptEntry() async {
    final User? currentUser = _auth.currentUser; // Get the current logged-in user

    if (currentUser != null && currentPrompt.isNotEmpty) {
      // Create a PromptEntry object to store in Firestore
      final promptEntry = PromptEntry(
        dateTime: DateTime.now(),
        prompt: currentPrompt,
        userID: currentUser.uid,
      );

      // Call the recordPrompt method in DatabaseService to save or update the prompt
      await _dbService.recordPrompt(promptEntry);
      print("Prompt entry recorded successfully.");
    } else {
      print("No user is logged in or prompt is empty. Unable to record the prompt.");
    }
  }

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
                        opacity: currentPrompt.isEmpty ? 0.0 : 1.0,
                        duration: Duration(seconds: 1),
                        child: Text(
                          currentPrompt,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            fontSize: 40,
                            color: const Color(0xFFFFFCF2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35.0),
                      ElevatedButton(
                        onPressed: () async {
                          await geminiFunctionCalling();
                        },
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
                      const SizedBox(height:20.0),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context, currentPrompt);
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
}
