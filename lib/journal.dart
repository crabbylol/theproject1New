import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:theproject1/calendardisplay.dart';
import 'package:theproject1/database_service.dart';
import 'package:theproject1/journalentry.dart';
import 'calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'day.dart';
import 'package:theproject1/auth_service.dart';
import 'dart:math';
import 'journalentry.dart';
import 'prompt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JournalPage extends StatefulWidget {
  final Day? day;

  const JournalPage({super.key, this.day});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late final model = GenerativeModel(
    apiKey: dotenv.env['OPENAI_API_KEY']!, model: 'gemini-pro');

  List<String> emotions = [];
  String resultEmotions = '';
  String advice = '';

  final TextEditingController _textEditingController = TextEditingController();
  final _dbServivce = DatabaseService();
  final _auth = FirebaseAuth.instance;
  String _selectedPrompt = '';

  Future<void> geminiFunctionCalling() async {
    print("Running analysis");
    String systemPrompt =
        "Act as a therapist and analyze the user's journal entry. Provide me with five emotions the user is feeling. Don’t need to give a reason behind why that user is feeling those emotion";
    String userPrompt =
        'Here is the journal entry: ${_textEditingController.text}'
        'Please only return the result in a string that only includes the words separated by commas';

    String userPrompt_advice = "Next, analysis this journal entry again. If the emotions are positive give encouraging words and ways to keep those positive emotions up. If emotions are negative give a 5 step actionable plan to do over the course of a week that is backed up by scientific evidence to improve those emotions while giving words of affirmation at the end.";

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
    //print(advice);

    if (!mounted) return;

    setState(() {
      emotions = resultEmotions.split(',');
      emotions = emotions.map((emotion) => emotion.trim()).toList();
      //print(emotions);
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeTextField();
  }

  void _initializeTextField() {
    _textEditingController.text = '\n' * 17;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 35.0, right: 15.0, left: 15.0),
                    child: Text(
                      '${DateFormat('M').format(DateTime.now())}/${DateFormat('d').format(DateTime.now())}/${DateFormat('y').format(DateTime.now())}:',
                      style: GoogleFonts.rubik(
                        fontStyle: FontStyle.italic,
                        fontSize: 35,
                        color: const Color(0xFF482BAD),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 35.0, right: 15.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalendarDisplayPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.close, size: 40, color: const Color(0xFFFFB12B)),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      'Hey,',
                      style: GoogleFonts.rubik(
                        fontSize: 75,
                        color: const Color(0xFFFFDE59),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Text(
                      'Name',
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.bold,
                        fontSize: 75,
                        color: const Color(0xFFFFB12B),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedPrompt.isNotEmpty)
                            Text(
                              _selectedPrompt,
                              style: GoogleFonts.rubik(
                                fontStyle: FontStyle.italic,
                                fontSize: 35,
                                color: const Color(0xFF482BAD),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
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
                            _selectedPrompt = selectedPrompt;
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
                  padding: const EdgeInsets.only(top: 8.0, right: 16.0, left: 16.0),
                  child: TextField(
                    // onChanged: (text) {
                    //   print('journal entry: $text (${text.characters.length})');
                    // },
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
                        borderSide: BorderSide(color: const Color(0xFFFFB12B), width: 2),
                      ),
                    ),
                    maxLines: 20,
                    minLines: 19,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, right: 15.0, left: 15.0, bottom: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      await geminiFunctionCalling();
                      final journalEntry = JournalEntry(dateTime: now, content: _textEditingController.text.trim(), userID: currentUser!.uid, emotions: emotions);
                      _dbServivce.create(journalEntry);
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
