import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:theproject1/auth_service.dart';
import 'package:theproject1/datedetailspage.dart';
import 'package:theproject1/day.dart';
import 'package:theproject1/loginpagewithemail.dart';
import 'database_service.dart';
import 'journal.dart';
import 'journalentry.dart';

class CalendarPage extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  const CalendarPage({Key? key, required this.initialYear, required this.initialMonth}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int year = 0;
  int month = 0;

  final _dbServivce = DatabaseService();
  Future<List<JournalEntry>>? monthlyEntries;

  late final model = GenerativeModel(
    apiKey: dotenv.env['OPENAI_API_KEY']!,
    model: 'gemini-pro',
  );

  List<String> emotions = [];
  String resultEmotions = '';

  // Future<void> geminiFunctionCalling() async {
  //   print("Running analysis");
  //
  //   // Revised system prompt:
  //   String systemPrompt =
  //       "Analyze the user's journal entries and identify the top three emotions the user might be feeling.";
  //
  //   // Combine all journal entries into a single string
  //   String userPrompt = '';
  //   await monthlyEntries!.then((entries) {
  //     for (var entry in entries) {
  //       userPrompt += entry.content + '\n';
  //     }
  //   });
  //
  //   // Pre-process the user prompt to remove unwanted characters (optional)
  //   userPrompt = userPrompt.replaceAll(RegExp(r'[0-9\.,\n]'), '');
  //
  //   final chat = model.startChat(history: [
  //     Content.text(userPrompt),
  //     Content.model([TextPart(systemPrompt)])
  //   ]);
  //
  //   final message = userPrompt;
  //   final response = await chat.sendMessage(Content.text(message));
  //
  //   print("Analysis ran, printing result:");
  //   resultEmotions = response.text!;
  //   print("Result printed.");
  //
  //   if (!mounted) return;
  //
  //   setState(() {
  //     // Extract the top three emotions using regular expressions
  //     final emotionRegex = RegExp(r'(?!emotions|is|are|feeling|feel)(\w+)\s*:\s*(.*)');
  //     final matches = emotionRegex.allMatches(resultEmotions);
  //
  //     emotions = matches.map((match) => match.group(1)!.toLowerCase()).toList();
  //     emotions = emotions.take(3).toList(); // Take only the top three emotions
  //
  //     print(emotions);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    year = widget.initialYear;
    month = widget.initialMonth;

    monthlyEntries = _dbServivce.getJournalEntriesByMonthYear(year, month);

    monthlyEntries!.then((entries) {
      // Access entries here
      //print("Number of entries: ${entries.length}");
      //geminiFunctionCalling();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _auth = AuthService();

    List<Day> daysInMonth = _generateDaysInMonth(year, month);
    List<String> dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    final firstDay = DateTime(year, month, 1);
    final weekdayOffset = (firstDay.weekday - DateTime.monday) % 7;

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Padding (
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
              child:_buildLogoutButton(AuthService(), context),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 115.0, bottom: 50.0),
              child: _buildMonthNavigation(
                dayNames: dayNames,
                daysInMonth: daysInMonth,
                weekdayOffset: weekdayOffset,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLogoutButton(AuthService auth, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JournalPage(),
              ),
            );
          },
          child: Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB12B),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: const Color(0xFFFFFCF2),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 18.0),
        GestureDetector(
          onTap: () async {
            await auth.signout();
            goToLogin(context);
          },
          child: Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB12B),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Icon(
                  Icons.logout_rounded,
                  size: 41,
                  color: const Color(0xFFFFFCF2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthNavigation({required List<String> dayNames, required List<Day> daysInMonth, required int weekdayOffset}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF110340),
        borderRadius: BorderRadius.circular(35),
      ),
      padding: EdgeInsets.only(top:55.0, left: 20.0, right: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      month--;
                      if (month == 0) {
                        month = 12;
                        year--;
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color(0xFFFFFCF2),
                    size: 35.0,
                  ),
                ),
                Text(
                  '${_getMonthName(month)} $year',
                  style: GoogleFonts.rubik(
                    color: const Color(0xFFFFB12B),
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      month++;
                      if (month == 13) {
                        month = 1;
                        year++;
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFFFFCF2),
                    size: 35.0,
                  ),
                ),
              ],
            ),
          ),
          _buildDayNames(dayNames),
          _buildDaysGrid(daysInMonth, weekdayOffset),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildDaysGrid(List<Day> daysInMonth, int weekdayOffset) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 20.0), // Add 20 px padding at the bottom
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: daysInMonth.length + weekdayOffset,
          itemBuilder: (BuildContext context, int index) {
            if (index < weekdayOffset) {
              return const SizedBox.shrink();
            }
            final day = daysInMonth[index - weekdayOffset];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DateDetailsPage(day: day)),
                );
              },
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '${day.date}',
                  style: GoogleFonts.rubik(
                    color: const Color(0xFFFFFCF2),
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayNames(List<String> dayNames) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: dayNames.map((name) {
        return Text(
          name,
          style: GoogleFonts.rubik(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: const Color(0xFFFFFCF2),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Container(
        decoration: BoxDecoration(
        color: Color(0xFF110340),
    borderRadius: BorderRadius.circular(35),
    ), child: Container(
      margin: const EdgeInsets.only(bottom: 95.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColorBox(Colors.red),
              _buildColorBox(Colors.green),
              _buildColorBox(Colors.blue),
            ],
          ),
        ],
      ),
    ),
    );
  }


  Widget _buildColorBox(Color color) {
    return Container(
      color: color,
      width: 100.0,
      height: 100.0,
    );
  }

  List<Day> _generateDaysInMonth(int year, int month) {
    List<Day> days = [];

    int daysInMonth = DateTime(year, month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(year, month, i);
      int weekday = date.weekday % 7;
      days.add(Day(date: i, weekday: weekday, month: month, year: year));
    }

    return days;
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPageWithEmail()),
    );
  }
}
