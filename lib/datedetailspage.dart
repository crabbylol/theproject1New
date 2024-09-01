import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'database_service.dart';
import 'day.dart';
import 'journalentry.dart';
import 'pastjournalentry.dart';
import 'journal.dart';

class DateDetailsPage extends StatefulWidget {
  final Day day;

  const DateDetailsPage({Key? key, required this.day}) : super(key: key);

  @override
  State<DateDetailsPage> createState() => _DateDetailsPageState();
}

class _DateDetailsPageState extends State<DateDetailsPage> {
  final _dbServivce = DatabaseService();
  DateTime todayDate = DateTime(0, 0, 0);
  Future<List<JournalEntry>>? todayEntries;

  @override
  void initState() {
    super.initState();
    todayDate = DateTime(widget.day.year, widget.day.month, widget.day.date);
    todayEntries = _dbServivce.getJournalEntriesByDate(todayDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color(0xFFFFFCF2),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0), // Add padding here
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${DateFormat('E, MMM d, yyyy').format(DateTime(widget.day.year, widget.day.month, widget.day.date))}:',
                        style: GoogleFonts.rubik(
                          fontSize: 35.0,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF110340),
                        ),
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
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      FutureBuilder<List<JournalEntry>>(
                        future: todayEntries,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else if (snapshot.hasData) {
                              final entries = snapshot.data!;
                              //print("List Length: ${entries.length}");
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: entries.length,
                                  itemBuilder: (context, index) {
                                    final entry = entries[index];
                                    final DateTime entryDateTime = entry.dateTime;
                                    final formatter = DateFormat('h');
                                    final hour = formatter.format(entryDateTime);
                                    final min = entryDateTime.minute;
                                    final String formattedMin = entryDateTime.minute > 9 ? '$min' : '0$min';
                                    final String amPm = entryDateTime.hour >= 12 ? 'PM' : 'AM';
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PastJournalEntryPage(day: widget.day, dateTime: entry.dateTime, content: entry.content, emotions: entry.emotions, entryNumber: index+1),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 175,
                                        margin: const EdgeInsets.only(bottom: 20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFB12B),
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Text(
                                                  '$hour:$formattedMin',
                                                  style: GoogleFonts.rubik(
                                                    fontSize: 90,
                                                    color: const Color(0xFFFFFCF2),
                                                    height: 0.9,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                '$amPm',
                                                style: GoogleFonts.rubik(
                                                  fontSize: 190,
                                                  color: const Color(0xFFFFFCF2).withOpacity(0.25),
                                                  height: 0.9,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                              );
                            } else {
                              return const Text("Something went wrong");
                            }
                          }
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
            ],
          ),
    );
  }
}