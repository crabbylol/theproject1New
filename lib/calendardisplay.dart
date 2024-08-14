import 'package:flutter/material.dart';
import 'calendar.dart';
import 'package:google_fonts/google_fonts.dart';


class CalendarDisplayPage extends StatelessWidget {
  const CalendarDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    return Scaffold(
      body: Stack(
        children: <Widget>[
      Container(
      height: double.infinity,
        width: double.infinity,
        color: const Color(0xFFFFFCF2),
      ),
          CalendarPage(initialYear: currentDate.year, initialMonth: currentDate.month,),
        ]
      ),
    );
  }
}
