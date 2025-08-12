import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'note_model.dart';
import 'services/firestore_service.dart';

class FeedTab extends StatefulWidget {
  final List<Note> publicNotes;
  const FeedTab({super.key, required this.publicNotes});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    if (widget.publicNotes.isEmpty) {
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
                Icons.public,
                size: isMobile ? 56 : 64,
                color: Colors.white.withOpacity(0.7),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'No public notes yet',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Text(
                'Be the first to share a note!',
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
      itemCount: widget.publicNotes.length,
      itemBuilder: (context, index) {
        final note = widget.publicNotes[index];
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
                        Icons.public,
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
                
                // Action buttons row
                Row(
                  children: [
                    // Upvote button
                    FutureBuilder<String?>(
                      future: _firestoreService.getUserVote(note.id!),
                      builder: (context, snapshot) {
                        final userVote = snapshot.data;
                        final isUpvoted = userVote == 'upvote';
                        
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_up,
                                color: isUpvoted ? Colors.green : Colors.grey,
                                size: isMobile ? 18 : 20,
                              ),
                              onPressed: () async {
                                if (isUpvoted) {
                                  await _firestoreService.removeVote(note.id!);
                                } else {
                                  await _firestoreService.upvoteNote(note.id!);
                                }
                                setState(() {});
                              },
                            ),
                            Text(
                              '${note.upvotes}',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.w600,
                                color: isUpvoted ? Colors.green : Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    SizedBox(width: isMobile ? 8 : 12),
                    
                    // Downvote button
                    FutureBuilder<String?>(
                      future: _firestoreService.getUserVote(note.id!),
                      builder: (context, snapshot) {
                        final userVote = snapshot.data;
                        final isDownvoted = userVote == 'downvote';
                        
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_down,
                                color: isDownvoted ? Colors.red : Colors.grey,
                                size: isMobile ? 18 : 20,
                              ),
                              onPressed: () async {
                                if (isDownvoted) {
                                  await _firestoreService.removeVote(note.id!);
                                } else {
                                  await _firestoreService.downvoteNote(note.id!);
                                }
                                setState(() {});
                              },
                            ),
                            Text(
                              '${note.downvotes}',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.w600,
                                color: isDownvoted ? Colors.red : Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const Spacer(),
                    
                    // Save button
                    FutureBuilder<bool>(
                      future: _firestoreService.isNoteSaved(note.id!),
                      builder: (context, snapshot) {
                        final isSaved = snapshot.data ?? false;
                        
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: isSaved ? Colors.orange : Colors.grey,
                                size: isMobile ? 18 : 20,
                              ),
                              onPressed: () async {
                                if (isSaved) {
                                  await _firestoreService.unsaveNote(note.id!);
                                } else {
                                  await _firestoreService.saveNote(note.id!);
                                }
                                setState(() {});
                              },
                            ),
                            Text(
                              '${note.savedByUsers.length}',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.w600,
                                color: isSaved ? Colors.orange : Colors.grey[600],
                              ),
                            ),
                          ],
                        );
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
