import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String? id;
  final String title;
  final String content;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final int upvotes;
  final int downvotes;
  final List<String> savedByUsers;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.isPublic,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.upvotes = 0,
    this.downvotes = 0,
    this.savedByUsers = const [],
  });

  // Create Note from Firestore document
  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      isPublic: data['isPublic'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      userId: data['userId'],
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      savedByUsers: List<String>.from(data['savedByUsers'] ?? []),
    );
  }

  // Convert Note to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'isPublic': isPublic,
      'userId': userId,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'savedByUsers': savedByUsers,
    };
  }

  // Create a copy of Note with updated fields
  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    int? upvotes,
    int? downvotes,
    List<String>? savedByUsers,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      savedByUsers: savedByUsers ?? this.savedByUsers,
    );
  }
}
