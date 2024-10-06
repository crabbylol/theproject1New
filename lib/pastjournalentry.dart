import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'day.dart';

class PastJournalEntryPage extends StatefulWidget {
  final Day day;
  final DateTime dateTime;
  final String content;
  final List<dynamic> emotions;
  final int entryNumber;
  final String advice;

  const PastJournalEntryPage({
    Key? key,
    required this.day,
    required this.dateTime,
    required this.content,
    required this.emotions,
    required this.entryNumber,
    required this.advice,
  }) : super(key: key);

  @override
  State<PastJournalEntryPage> createState() => _PastJournalEntryPageState();
}

class _PastJournalEntryPageState extends State<PastJournalEntryPage> {
  bool isAdviceExpanded = false;
  bool isJournalEntryExpanded = false;

  String processAdvice(String advice) {
    String noSubsectionTitles = advice.replaceAll(RegExp(r'\*\*.*?:\*\*'), '');
    return noSubsectionTitles.replaceAll('*', '').replaceAll(RegExp(r'\n{2,}'), '\n\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFFFCF2),
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20.0),
            _buildEmotionTag(),
            const SizedBox(height: 20.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildExpansionTile(
                      title: "Advice",
                      content: processAdvice(widget.advice),
                      isExpanded: isAdviceExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          isAdviceExpanded = expanded;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    _buildExpansionTile(
                      title: "Journal Entry",
                      content: widget.content,
                      isExpanded: isJournalEntryExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          isJournalEntryExpanded = expanded;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
          icon: const Icon(Icons.close, size: 40, color: Color(0xFFFFB12B)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildEmotionTag() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB12B),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text(
        widget.emotions.isNotEmpty ? widget.emotions[0] : "",
        style: GoogleFonts.rubik(
          fontSize: 35,
          color: const Color(0xFFFFFCF2),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required String content,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: GoogleFonts.rubik(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF482BAD),
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          size: 35,
          color: const Color(0xFF482BAD),
        ),
        onExpansionChanged: onExpansionChanged,
        tilePadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              content,
              style: GoogleFonts.rubik(
                fontSize: 18,
                color: const Color(0xFF482BAD),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}