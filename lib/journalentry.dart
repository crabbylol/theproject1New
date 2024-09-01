class JournalEntry {
  // int primarymood;
  // int secondarymood;
  // int tertiarymood;
  DateTime dateTime;
  String content;
  String userID;
  List<dynamic> emotions;

  JournalEntry({
    // required this.primarymood,
    // required this.secondarymood,
    // required this.tertiarymood,
    required this.dateTime,
    required this.content,
    required this.userID,
    required this.emotions
  });
}