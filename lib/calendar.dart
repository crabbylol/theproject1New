import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

// Project-specific imports
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

  final _dbService = DatabaseService();
  Future<List<JournalEntry>>? monthlyEntries;

  late final model = GenerativeModel(
    apiKey: dotenv.env['OPENAI_API_KEY']!,
    model: 'gemini-pro',
  );

  List<String> emotions = [];
  String resultEmotions = '';

  @override
  void initState() {
    super.initState();
    year = widget.initialYear;
    month = widget.initialMonth;
    monthlyEntries = _dbService.getJournalEntriesByMonthYear(year, month);
  }

  @override
  Widget build(BuildContext context) {
    final _auth = AuthService();
    List<Day> daysInMonth = _generateDaysInMonth(year, month);
    List<String> dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    final firstDay = DateTime(year, month, 1);
    final weekdayOffset = (firstDay.weekday - DateTime.monday) % 7;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),
      body: Center(
        child: Stack(
          children: [
            // Logout button
            _buildLogoutSection(_auth, context),

            // Calendar navigation and day grid
            _buildCalendarSection(dayNames, daysInMonth, weekdayOffset),
          ],
        ),
      ),
    );
  }

  // Extracting smaller widget methods

  Widget _buildLogoutSection(AuthService auth, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildIconButton(
            icon: Icons.add,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => JournalPage()));
            },
          ),
          const SizedBox(width: 18.0),
          _buildIconButton(
            icon: Icons.logout_rounded,
            onPressed: () async {
              await auth.signout();
              goToLogin(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
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
            child: Icon(icon, size: 40, color: const Color(0xFFFFFCF2)),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection(List<String> dayNames, List<Day> daysInMonth, int weekdayOffset) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 115.0, bottom: 50.0),
      child: _buildMonthNavigation(dayNames, daysInMonth, weekdayOffset),
    );
  }

  Widget _buildMonthNavigation(List<String> dayNames, List<Day> daysInMonth, int weekdayOffset) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF110340),
        borderRadius: BorderRadius.circular(35),
      ),
      padding: const EdgeInsets.only(top: 70.0, left: 20.0, right: 20.0),
      child: Column(
        children: [
          _buildMonthHeader(),
          _buildDayNames(dayNames),
          _buildDaysGrid(daysInMonth, weekdayOffset),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFFFFCF2), size: 35.0),
          ),
          Text(
            '${_getMonthName(month)} $year',
            style: GoogleFonts.rubik(color: const Color(0xFFFFB12B), fontWeight: FontWeight.w800, fontSize: 30),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFFCF2), size: 35.0),
          ),
        ],
      ),
    );
  }

  // Logic for navigating months
  void _previousMonth() {
    setState(() {
      month--;
      if (month == 0) {
        month = 12;
        year--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      month++;
      if (month == 13) {
        month = 1;
        year++;
      }
    });
  }

  Widget _buildDayNames(List<String> dayNames) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: dayNames.map((name) {
        return Text(
          name,
          style: GoogleFonts.rubik(fontWeight: FontWeight.w500, fontSize: 20, color: const Color(0xFFFFFCF2)),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid(List<Day> daysInMonth, int weekdayOffset) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemCount: daysInMonth.length + weekdayOffset,
          itemBuilder: (BuildContext context, int index) {
            if (index < weekdayOffset) return const SizedBox.shrink();
            final day = daysInMonth[index - weekdayOffset];
            return GestureDetector(
              onTap: () => _navigateToDayDetails(day),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '${day.date}',
                  style: GoogleFonts.rubik(color: const Color(0xFFFFFCF2), fontWeight: FontWeight.w400, fontSize: 20),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToDayDetails(Day day) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DateDetailsPage(day: day)));
  }

  // Helper methods

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
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }

  void goToLogin(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPageWithEmail()));
  }
}
