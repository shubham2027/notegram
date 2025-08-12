import 'package:flutter/material.dart';
import 'note_model.dart';

class NoteEditorScreen extends StatefulWidget {
  final void Function(Note) onSave;
  final Note? note;
  const NoteEditorScreen({super.key, required this.onSave, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _isPublic = widget.note!.isPublic;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;
    final note = Note(title: title, content: content, isPublic: _isPublic);
    widget.onSave(note);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    // Adjust padding based on screen size
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 16.0 : 24.0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Edit Note' : 'Add Note'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              children: [
                // Header Section - Reduced size on mobile
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.sticky_note_2,
                        size: isMobile ? 48 : 60,
                        color: Colors.white,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        widget.note != null ? 'Edit Your Note' : 'Create New Note',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                
                // Form Card - Optimized for mobile
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        Text(
                          'Title',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: isMobile ? 6 : 8),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Enter note title...',
                            prefixIcon: const Icon(Icons.title, color: Color(0xFF667eea)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 12 : 16,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        
                        // Content Field - Always visible and properly sized
                        Text(
                          'Content',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: isMobile ? 6 : 8),
                        Expanded(
                          child: TextField(
                            controller: _contentController,
                            decoration: InputDecoration(
                              hintText: 'Write your note content here...',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
                            ),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        
                        // Public/Private Toggle - Optimized for mobile
                        Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                            border: Border.all(
                              color: _isPublic 
                                  ? const Color(0xFF667eea).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isPublic ? Icons.public : Icons.lock,
                                color: _isPublic 
                                    ? const Color(0xFF667eea)
                                    : Colors.grey[600],
                                size: isMobile ? 20 : 24,
                              ),
                              SizedBox(width: isMobile ? 8 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isPublic ? 'Public Note' : 'Private Note',
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                        color: _isPublic 
                                            ? const Color(0xFF667eea)
                                            : Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      _isPublic 
                                          ? 'This note will be visible to everyone'
                                          : 'This note will only be visible to you',
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isPublic,
                                onChanged: (value) {
                                  setState(() {
                                    _isPublic = value;
                                  });
                                },
                                activeColor: const Color(0xFF667eea),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 20 : 24),
                        
                        // Save Button - Full width and properly sized
                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 48 : 56,
                          child: ElevatedButton(
                            onPressed: _saveNote,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                              ),
                            ),
                            child: Text(
                              widget.note != null ? 'Update Note' : 'Save Note',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
