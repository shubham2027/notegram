import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'feed_tab.dart';
import 'my_notes_tab.dart';
import 'note_editor_screen.dart';
import 'profile_screen.dart';
import 'note_model.dart';
import 'services/firestore_service.dart';
import 'services/theme_provider.dart';
import 'auth_screen.dart';

class HomePage extends StatefulWidget {
  final String email;
  const HomePage({super.key, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _tabIndex = 1; // Start on My Notes tab by default
  bool _welcomeShown = false;

  @override
  void initState() {
    super.initState();
    // Show welcome dialog after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_welcomeShown && mounted) {
        _welcomeShown = true;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Welcome to Notegram! 👍',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'You\'re all set. Start capturing your ideas in My Notes or explore public notes in the Feed.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Let\'s go'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _addNote(Note note) async {
    try {
      await _firestoreService.addNote(note);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding note: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _editNote(int index, Note updatedNote) async {
    try {
      // Get the note ID from the stream
      final notes = await _firestoreService.getUserNotes().first;
      if (index < notes.length) {
        final noteId = notes[index].id;
        if (noteId != null) {
          await _firestoreService.updateNote(noteId, updatedNote);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating note: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _deleteNote(String noteId) async {
    try {
      await _firestoreService.deleteNote(noteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note deleted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting note: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _logout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    return DefaultTabController(
      length: 3,
      initialIndex: 1, // My Notes tab
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notegram',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 20 : 24,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          bottom: TabBar(
            onTap: (i) => setState(() => _tabIndex = i),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 12 : 14,
            ),
            tabs: [
              Tab(
                icon: Icon(Icons.public, size: isMobile ? 20 : 24),
                text: 'Feed',
              ),
              Tab(
                icon: Icon(Icons.lock, size: isMobile ? 20 : 24),
                text: 'My Notes',
              ),
              Tab(
                icon: Icon(Icons.person, size: isMobile ? 20 : 24),
                text: 'Profile',
              ),
            ],
          ),
        ),
        body: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.gradientColors,
                ),
              ),
              child: TabBarView(
                children: [
                  StreamBuilder<List<Note>>(
                    stream: _firestoreService.getPublicNotes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      }
                      return FeedTab(publicNotes: snapshot.data!);
                    },
                  ),
                  StreamBuilder<List<Note>>(
                    stream: _firestoreService.getUserNotes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      }
                      return MyNotesTab(privateNotes: snapshot.data!, onEdit: _editNote, onDelete: _deleteNote);
                    },
                  ),
                  ProfileScreen(email: widget.email, onLogout: _logout),
                ],
              ),
            );
          },
        ),
        floatingActionButton: _tabIndex != 2
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    final note = await Navigator.push<Note>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteEditorScreen(
                          onSave: (n) => Navigator.pop(context, n),
                        ),
                      ),
                    );
                    if (note != null) _addNote(note);
                  },
                  icon: Icon(Icons.add, size: isMobile ? 20 : 24),
                  label: Text(
                    'Add Note',
                    style: TextStyle(fontSize: isMobile ? 14 : 16),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF667eea),
                  elevation: 0,
                ),
              )
            : null,
      ),
    );
  }
}
