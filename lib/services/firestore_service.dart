import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../note_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's private notes
  Stream<List<Note>> getUserNotes() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromFirestore(doc))
            .toList());
  }

  // Get public notes
  Stream<List<Note>> getPublicNotes() {
    return _firestore
        .collection('public_notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromFirestore(doc))
            .toList());
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final noteData = note.toFirestore();
    noteData['userId'] = user.uid;
    noteData['createdAt'] = FieldValue.serverTimestamp();
    noteData['updatedAt'] = FieldValue.serverTimestamp();

    // Add to user's private notes
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .add(noteData);

    // If public, also add to public notes
    if (note.isPublic) {
      await _firestore.collection('public_notes').add(noteData);
    }
  }

  // Update a note
  Future<void> updateNote(String noteId, Note updatedNote) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final noteData = updatedNote.toFirestore();
    noteData['updatedAt'] = FieldValue.serverTimestamp();

    // Update in user's private notes
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(noteId)
        .update(noteData);

    // Handle public notes
    if (updatedNote.isPublic) {
      // Check if it exists in public notes
      final publicQuery = await _firestore
          .collection('public_notes')
          .where('userId', isEqualTo: user.uid)
          .where('title', isEqualTo: updatedNote.title)
          .get();

      if (publicQuery.docs.isNotEmpty) {
        // Update existing public note
        await publicQuery.docs.first.reference.update(noteData);
      } else {
        // Add new public note
        noteData['userId'] = user.uid;
        noteData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('public_notes').add(noteData);
      }
    } else {
      // Remove from public notes if now private
      final publicQuery = await _firestore
          .collection('public_notes')
          .where('userId', isEqualTo: user.uid)
          .where('title', isEqualTo: updatedNote.title)
          .get();

      for (var doc in publicQuery.docs) {
        await doc.reference.delete();
      }
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get the note to check if it's public
    final noteDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(noteId)
        .get();

    if (noteDoc.exists) {
      final noteData = noteDoc.data();
      final title = noteData?['title'] ?? '';

      // Delete from user's private notes
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(noteId)
          .delete();

      // Also remove from public notes if it was public
      if (noteData?['isPublic'] == true) {
        final publicQuery = await _firestore
            .collection('public_notes')
            .where('userId', isEqualTo: user.uid)
            .where('title', isEqualTo: title)
            .get();

        for (var doc in publicQuery.docs) {
          await doc.reference.delete();
        }
      }
    }
  }

  // Upvote a public note
  Future<void> upvoteNote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final noteRef = _firestore.collection('public_notes').doc(noteId);
    final userVoteDoc = _firestore
        .collection('user_votes')
        .doc('${user.uid}_$noteId');
    
    await _firestore.runTransaction((transaction) async {
      final noteDoc = await transaction.get(noteRef);
      if (!noteDoc.exists) return;

      final userVote = await transaction.get(userVoteDoc);
      String? previousVote;
      
      if (userVote.exists) {
        previousVote = userVote.data()?['vote'] as String?;
        // Remove previous vote if exists
        if (previousVote == 'upvote') return; // Already upvoted
        if (previousVote == 'downvote') {
          final currentDownvotes = noteDoc.data()?['downvotes'] ?? 0;
          transaction.update(noteRef, {'downvotes': currentDownvotes - 1});
        }
      }

      // Add new upvote
      final currentUpvotes = noteDoc.data()?['upvotes'] ?? 0;
      transaction.update(noteRef, {'upvotes': currentUpvotes + 1});
      
      // Record user's vote
      transaction.set(userVoteDoc, {
        'userId': user.uid,
        'noteId': noteId,
        'vote': 'upvote',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  // Downvote a public note
  Future<void> downvoteNote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final noteRef = _firestore.collection('public_notes').doc(noteId);
    final userVoteDoc = _firestore
        .collection('user_votes')
        .doc('${user.uid}_$noteId');
    
    await _firestore.runTransaction((transaction) async {
      final noteDoc = await transaction.get(noteRef);
      if (!noteDoc.exists) return;

      final userVote = await transaction.get(userVoteDoc);
      String? previousVote;
      
      if (userVote.exists) {
        previousVote = userVote.data()?['vote'] as String?;
        // Remove previous vote if exists
        if (previousVote == 'downvote') return; // Already downvoted
        if (previousVote == 'upvote') {
          final currentUpvotes = noteDoc.data()?['upvotes'] ?? 0;
          transaction.update(noteRef, {'upvotes': currentUpvotes - 1});
        }
      }

      // Add new downvote
      final currentDownvotes = noteDoc.data()?['downvotes'] ?? 0;
      transaction.update(noteRef, {'downvotes': currentDownvotes + 1});
      
      // Record user's vote
      transaction.set(userVoteDoc, {
        'userId': user.uid,
        'noteId': noteId,
        'vote': 'downvote',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  // Save a public note to user's private notes
  Future<void> saveNote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get the public note
    final publicNoteDoc = await _firestore.collection('public_notes').doc(noteId).get();
    if (!publicNoteDoc.exists) throw Exception('Note not found');

    final publicNoteData = publicNoteDoc.data()!;
    
    // Create a new private note with the public note content
    final privateNoteData = {
      'title': publicNoteData['title'],
      'content': publicNoteData['content'],
      'isPublic': false, // Always private when saved
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'originalNoteId': noteId, // Reference to original public note
    };

    // Add to user's private notes
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .add(privateNoteData);

    // Update the public note's savedByUsers list
    final noteRef = _firestore.collection('public_notes').doc(noteId);
    await _firestore.runTransaction((transaction) async {
      final noteDoc = await transaction.get(noteRef);
      if (noteDoc.exists) {
        final currentSavedBy = List<String>.from(noteDoc.data()?['savedByUsers'] ?? []);
        if (!currentSavedBy.contains(user.uid)) {
          currentSavedBy.add(user.uid);
          transaction.update(noteRef, {'savedByUsers': currentSavedBy});
        }
      }
    });
  }

  // Check if a note is saved by current user
  Future<bool> isNoteSaved(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final noteDoc = await _firestore.collection('public_notes').doc(noteId).get();
    if (!noteDoc.exists) return false;

    final savedByUsers = List<String>.from(noteDoc.data()?['savedByUsers'] ?? []);
    return savedByUsers.contains(user.uid);
  }

  // Unsave a note (remove from user's private notes)
  Future<void> unsaveNote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Remove from public note's savedByUsers list
    final noteRef = _firestore.collection('public_notes').doc(noteId);
    await _firestore.runTransaction((transaction) async {
      final noteDoc = await transaction.get(noteRef);
      if (noteDoc.exists) {
        final currentSavedBy = List<String>.from(noteDoc.data()?['savedByUsers'] ?? []);
        if (currentSavedBy.contains(user.uid)) {
          currentSavedBy.remove(user.uid);
          transaction.update(noteRef, {'savedByUsers': currentSavedBy});
        }
      }
    });

    // Find and remove the saved note from user's private notes
    final userNotesQuery = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .where('originalNoteId', isEqualTo: noteId)
        .get();

    for (var doc in userNotesQuery.docs) {
      await doc.reference.delete();
    }
  }

  // Get user's current vote on a note
  Future<String?> getUserVote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userVotesDoc = await _firestore
        .collection('user_votes')
        .doc('${user.uid}_$noteId')
        .get();

    if (userVotesDoc.exists) {
      return userVotesDoc.data()?['vote'] as String?;
    }
    return null;
  }

  // Remove user's vote from a note
  Future<void> removeVote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userVoteDoc = _firestore
        .collection('user_votes')
        .doc('${user.uid}_$noteId');

    final userVote = await userVoteDoc.get();
    if (!userVote.exists) return;

    final voteType = userVote.data()?['vote'] as String?;
    if (voteType == null) return;

    // Remove the user vote document
    await userVoteDoc.delete();

    // Update the note's vote count
    final noteRef = _firestore.collection('public_notes').doc(noteId);
    await _firestore.runTransaction((transaction) async {
      final noteDoc = await transaction.get(noteRef);
      if (noteDoc.exists) {
        if (voteType == 'upvote') {
          final currentUpvotes = noteDoc.data()?['upvotes'] ?? 0;
          transaction.update(noteRef, {'upvotes': currentUpvotes - 1});
        } else if (voteType == 'downvote') {
          final currentDownvotes = noteDoc.data()?['downvotes'] ?? 0;
          transaction.update(noteRef, {'downvotes': currentDownvotes - 1});
        }
      }
    });
  }
}
