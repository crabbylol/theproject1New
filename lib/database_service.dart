import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theproject1/journalentry.dart';
import 'package:theproject1/promptEntry.dart';

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
        "emotions" : journalEntry.emotions,
        "advice": journalEntry.advice
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> recordPrompt(PromptEntry promptEntry) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print("No user is currently logged in!");
      return;
    }

    try {
      // Set up a reference to the 'prompts' collection.
      final promptCollection = _fire.collection("prompts");

      // Calculate start and end of today's date in UTC.
      final DateTime todayStart = DateTime(promptEntry.dateTime.year, promptEntry.dateTime.month, promptEntry.dateTime.day);
      final DateTime todayEnd = todayStart.add(const Duration(days: 1));

      // Check if a prompt for today already exists for the current user.
      final query = await promptCollection
          .where("userID", isEqualTo: promptEntry.userID)
          .where("dateTime", isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where("dateTime", isLessThan: Timestamp.fromDate(todayEnd))
          .get();

      if (query.docs.isNotEmpty) {
        // If a prompt entry already exists, update it with the new prompt.
        final existingDoc = query.docs.first;
        await promptCollection.doc(existingDoc.id).update({
          "prompt": promptEntry.prompt,
          "dateTime": Timestamp.fromDate(promptEntry.dateTime), // Update the dateTime if necessary
        });
        print("Prompt updated successfully for today's date.");
      } else {
        // If no prompt entry exists for today, create a new entry.
        await promptCollection.add({
          "dateTime": Timestamp.fromDate(promptEntry.dateTime),
          "prompt": promptEntry.prompt,
          "userID": promptEntry.userID,
        });
        print("New prompt entry created for today's date.");
      }
    } catch (e) {
      print("Error in recording prompt: $e");
    }
  }

  Future<PromptEntry?> getPromptForToday() async {
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        final DateTime todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        final DateTime todayEnd = todayStart.add(const Duration(days: 1));

        // Query the prompts collection for today's date and the current user's ID
        final querySnapshot = await _fire
            .collection("prompts")
            .where("userID", isEqualTo: currentUser.uid)
            .where("dateTime", isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
            .where("dateTime", isLessThan: Timestamp.fromDate(todayEnd))
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final promptDoc = querySnapshot.docs.first;
          final promptData = promptDoc.data() as Map<String, dynamic>;

          // Convert Firestore data to PromptEntry object
          return PromptEntry(
            dateTime: (promptData["dateTime"] as Timestamp).toDate(),
            prompt: promptData["prompt"],
            userID: promptData["userID"],
          );
        } else {
          print("No prompt found for today's date.");
          return null;
        }
      } catch (e) {
        print("Error retrieving prompt for today: $e");
        return null;
      }
    } else {
      print("No user is currently logged in!");
      return null;
    }
  }

  Future<List<JournalEntry>> getJournalEntriesByDate(DateTime selectedDate) async {
    final User? currentUser = _auth.currentUser;
    final selectedDateUtc = selectedDate.toUtc();

    if (currentUser != null) {
      final DateTime startDate = DateTime(selectedDateUtc.year, selectedDateUtc.month, selectedDateUtc.day);
      final DateTime endDate = startDate.add(const Duration(days: 1));

      //print(currentUser.uid);
      //print(Timestamp.fromDate(startDate));
      //print(Timestamp.fromDate(endDate));

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
          emotions: doc['emotions'],
          advice: doc['advice']
        );
      }).toList();

      return entries;
    } else {
      print("No user is currently logged in!");
      return [];
    }
  }

  Future<List<JournalEntry>> getJournalEntriesByMonthYear(int year, int month) async {
    //print("Year: ${year}");
    //print("Month: ${month}");

    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final DateTime firstDayOfMonth = DateTime(year, month, 1);
      final DateTime lastDayOfMonth = DateTime(year, month + 1, 0); // Get last day of previous month (zero-based indexing)

      final query = _fire
          .collection("journalEntries")
          .where('userID', isEqualTo: currentUser.uid)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
          .where('dateTime', isLessThan: Timestamp.fromDate(lastDayOfMonth.add(const Duration(days: 1))));  // Add 1 day to include entries on the last day

      final querySnapshot = await query.get();

      final entries = querySnapshot.docs.map((doc) {
        return JournalEntry(
          dateTime: (doc['dateTime'] as Timestamp).toDate(),
          content: doc['content'],
          userID: doc['userID'],
          emotions: doc['emotions'],
          advice: doc['advice']
        );
      }).toList();

      return entries;
    } else {
      print("No user is currently logged in!");
      return [];
    }
  }
}