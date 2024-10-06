import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:theproject1/calendardisplay.dart';
import 'package:theproject1/database_service.dart';
import 'package:theproject1/journalentry.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'day.dart';
import 'package:theproject1/auth_service.dart';
import 'prompt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:theproject1/promptEntry.dart'; // Import PromptEntry

class JournalPage extends StatefulWidget {
  final Day? day;

  const JournalPage({super.key, this.day});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late final model = GenerativeModel(
      apiKey: dotenv.env['OPENAI_API_KEY']!, model: 'gemini-pro');

  final _authService = AuthService();
  String _username = '';
  List<String> emotions = [];
  String resultEmotions = '';
  String advice = '';
  String _todayPrompt = '';

  final TextEditingController _textEditingController = TextEditingController();
  final _dbService = DatabaseService(); // Corrected spelling
  final _auth = FirebaseAuth.instance;

  Future<void> _fetchUsername() async {
    String? username = await _authService
        .getCurrentUsername(); // Fetch the username
    if (username != null) {
      setState(() {
        _username = username; // Store it in the state
      });
    }
  }

  // New method to fetch today's prompt
  Future<void> _fetchTodayPrompt() async {
    final promptEntry = await _dbService.getPromptForToday();
    if (promptEntry != null) {
      setState(() {
        _todayPrompt =
            promptEntry.prompt; // Update the state with today's prompt
      });
    } else {
      setState(() {
        _todayPrompt =
        "No prompt available for today."; // Fallback if no prompt is found
      });
    }
  }

  Future<void> geminiFunctionCalling() async {
    print("Running analysis");
    String systemPrompt =
        "Act as a therapist and analyze the user's journal entry. Provide me with five emotions the user is feeling. Don’t need to give a reason behind why that user is feeling those emotions.";
    String userPrompt =
        'Here is the journal entry: ${_textEditingController
        .text}. Please only return the result in a string that only includes the words separated by commas';

    String userPrompt_advice = "Analyze this journal entry (without printing it out). Provide encouraging words, followed by a 5-step actionable plan (number each step) to be completed over the course of a week. The plan should be backed by scientific evidence and past journal entries to understand the person's character and improve their emotions. Conclude with additional words of affirmation. Ensure that the response is in plain font and that there are no subsection titles or bold formatting.";

    final chat = model.startChat(history: [
      Content.text(userPrompt),
      Content.model([TextPart(systemPrompt)])
    ]);

    final message = userPrompt;
    final response = await chat.sendMessage(Content.text(message));

    print("Analysis ran, printing result:");
    resultEmotions = response.text!;
    print("Result printed.");

    final getAdvice = userPrompt_advice;
    final response_advice = await chat.sendMessage(Content.text(getAdvice));

    advice = response_advice.text!;

    if (!mounted) return;

    setState(() {
      emotions = resultEmotions.split(',');
      emotions = emotions.map((emotion) => emotion.trim()).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeTextField();
    _fetchUsername(); // Call the method to fetch the username
    _fetchTodayPrompt(); // Call the method to fetch today's prompt
  }

  void _initializeTextField() {
    _textEditingController.text = '\n' * 17;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color(0xFFFFFCF2),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 35.0, right: 20.0, left: 20.0),
                    child: Text(
                      '${DateFormat('M').format(DateTime.now())}/${DateFormat(
                          'd').format(DateTime.now())}/${DateFormat('y').format(
                          DateTime.now())}:',
                      style: GoogleFonts.rubik(
                        fontStyle: FontStyle.italic,
                        fontSize: 25,
                        color: const Color(0xFF482BAD),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, right: 20.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalendarDisplayPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.close, size: 40,
                          color: const Color(0xFFFFB12B)),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, left: 20.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hey, ',
                            style: GoogleFonts.rubik(
                              fontSize: 45,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFFFDE59),
                            ),
                          ),
                          TextSpan(
                            text: _username.isNotEmpty ? _username : 'there',
                            style: GoogleFonts.rubik(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFB12B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display _todayPrompt in the Text widget
                          Text(
                            _todayPrompt.isNotEmpty
                                ? _todayPrompt
                                : "Loading today's prompt...",
                            style: GoogleFonts.rubik(
                              fontStyle: FontStyle.italic,
                              fontSize: 30,
                              color: const Color(0xFF482BAD),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Navigate to the PromptPage and wait for the returned prompt.
                        final selectedPrompt = await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => PromptPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, -1.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var fadeTween = Tween(begin: 0.0, end: 1.0);

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: FadeTransition(
                                  opacity: animation.drive(fadeTween),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration: const Duration(seconds: 1),
                          ),
                        );


                        if (selectedPrompt != null) {
                          setState(() {
                            _todayPrompt = selectedPrompt;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFFD38BF5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 20.0,
                          color: const Color(0xFFFFFCF2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, right: 16.0, left: 16.0),
                  child: TextField(
                    controller: _textEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelStyle: GoogleFonts.rubik(
                        fontSize: 20.0,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFF6D4),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFFFB12B),
                            width: 2),
                      ),
                    ),
                    maxLines: 20,
                    minLines: 19,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 30.0, right: 15.0, left: 15.0, bottom: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      await geminiFunctionCalling();
                      final journalEntry = JournalEntry(dateTime: now,
                          content: _textEditingController.text.trim(),
                          userID: currentUser!.uid,
                          emotions: emotions,
                          advice: advice);
                      _dbService.create(journalEntry);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalendarDisplayPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFF482BAD),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'SUBMIT',
                        maxLines: 1,
                        style: GoogleFonts.rubik(
                          fontSize: 40,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFFCF2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}