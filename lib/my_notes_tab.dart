import 'package:flutter/material.dart';
import 'note_model.dart';
import 'note_editor_screen.dart';

class MyNotesTab extends StatelessWidget {
  final List<Note> privateNotes;
  final void Function(int, Note) onEdit;
  final void Function(String noteId) onDelete;
  const MyNotesTab({
    super.key,
    required this.privateNotes,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    if (privateNotes.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock,
                size: isMobile ? 56 : 64,
                color: Colors.white.withOpacity(0.7),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'No notes yet',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Text(
                'Create your first note using the + button!',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      itemCount: privateNotes.length,
      itemBuilder: (context, index) {
        final note = privateNotes[index];
        return Container(
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                      ),
                      child: Icon(
                        Icons.lock,
                        color: const Color(0xFF667eea),
                        size: isMobile ? 16 : 20,
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        note.title,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 8 : 12),
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                if (note.createdAt != null) ...[
                  SizedBox(height: isMobile ? 12 : 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: isMobile ? 14 : 16,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: isMobile ? 4 : 6),
                      Text(
                        _formatDate(note.createdAt!),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: isMobile ? 12 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                        color: note.isPublic 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 8,
                        vertical: isMobile ? 3 : 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            note.isPublic ? Icons.public : Icons.lock,
                            size: isMobile ? 12 : 14,
                            color: note.isPublic ? Colors.green : Colors.grey,
                          ),
                          SizedBox(width: isMobile ? 3 : 4),
                          Text(
                            note.isPublic ? 'Public' : 'Private',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 12,
                              fontWeight: FontWeight.w500,
                              color: note.isPublic ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: const Color(0xFF667eea),
                        size: isMobile ? 20 : 24,
                      ),
                      onPressed: () async {
                        final updatedNote = await Navigator.push<Note>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteEditorScreen(
                              note: note,
                              onSave: (updatedNote) => Navigator.pop(context, updatedNote),
                            ),
                          ),
                        );
                        if (updatedNote != null) {
                          onEdit(index, updatedNote);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: isMobile ? 20 : 24,
                      ),
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                            ),
                            title: Text(
                              'Delete Note',
                              style: TextStyle(fontSize: isMobile ? 18 : 20),
                            ),
                            content: Text(
                              'Are you sure you want to delete "${note.title}"?',
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                                ),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ],
                          ),
                        );
                        
                        if (shouldDelete == true && note.id != null) {
                          onDelete(note.id!);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
