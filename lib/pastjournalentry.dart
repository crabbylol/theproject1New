import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'day.dart';
import 'journalentry.dart';

class PastJournalEntryPage extends StatefulWidget {
  final Day day;
  final DateTime dateTime;
  final String content;
  final List<dynamic> emotions;
  final int entryNumber;

  const PastJournalEntryPage({
    Key? key,
    required this.day,
    required this.dateTime,
    required this.content,
    required this.emotions,
    required this.entryNumber,
  }) : super(key: key);

  @override
  State<PastJournalEntryPage> createState() => _PastJournalEntryPageState();
}

class _PastJournalEntryPageState extends State<PastJournalEntryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
            color: const Color(0xFFFFFCF2),
            child: Padding (
              padding: EdgeInsets.all (30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.MMMEd().format(widget.dateTime),
                        style: GoogleFonts.rubik(
                          fontSize: 40.0,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF110340),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 40, color: const Color(0xFFFFB12B)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB12B),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Text(
                      widget.emotions.isNotEmpty? widget.emotions [0]: "",
                      style: GoogleFonts.rubik(
                        fontSize: 35,
                        color: const Color(0xFFFFFCF2),
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: Column (
                      children: <Widget> [
                        Expanded(
                          child: ExpansionTile(
                            title: Text(
                              "Advice",
                              style: GoogleFonts.rubik(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF482BAD),
                              ),
                            ),
                            trailing: Icon(
                                Icons.arrow_drop_down_circle
                            ),
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF6D4),
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    "blah",
                                    style: GoogleFonts.rubik(
                                      fontSize: 24,
                                      color: const Color(0xFF482BAD),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ExpansionTile(
                            title: Text(
                              "Journal Entry ${widget.entryNumber}",
                              style: GoogleFonts.rubik(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF482BAD),
                              ),
                            ),
                            trailing: Icon(
                                  Icons.arrow_drop_down_circle
                            ),
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF6D4),
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    widget.content,
                                    style: GoogleFonts.rubik(
                                      fontSize: 24,
                                      color: const Color(0xFF482BAD),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
