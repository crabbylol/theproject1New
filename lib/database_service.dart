import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theproject1/journalentry.dart';

import 'auth_service.dart';

class DatabaseService {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  create(JournalEntry journalEntry) {
    //final User? currentUser = _auth.currentUser;
    try {
      _fire.collection("journalEntries").add({
        "dateTime": Timestamp.fromDate(journalEntry.dateTime),
        "content": journalEntry.content,
        "userID": journalEntry.userID,
        "emotions" : journalEntry.emotions
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<JournalEntry>> getJournalEntriesByDate(DateTime selectedDate) async {
    final User? currentUser = _auth.currentUser;
    final selectedDateUtc = selectedDate.toUtc();

    if (currentUser != null) {
      final DateTime startDate = DateTime(selectedDateUtc.year, selectedDateUtc.month, selectedDateUtc.day);
      final DateTime endDate = startDate.add(const Duration(days: 1));

      print(currentUser.uid);
      print(Timestamp.fromDate(startDate));
      print(Timestamp.fromDate(endDate));

      final query = _fire
        .collection("journalEntries")
        .where('userID', isEqualTo: currentUser.uid)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('dateTime', isLessThan: Timestamp.fromDate(endDate));

      final querySnapshot = await query.get();

      //print("Number of entries retrieved: ${querySnapshot.docs.length}");

      final entries = querySnapshot.docs.map((doc) {
        return JournalEntry(
          dateTime: (doc['dateTime'] as Timestamp).toDate(),
          content: doc['content'],
          userID: doc['userID'],
          emotions: doc['emotions']
        );
      }).toList();

      return entries;
    } else {
      print("No user is currently logged in!");
      return [];
    }
  }
}