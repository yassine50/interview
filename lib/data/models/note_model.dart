import 'package:flutter/foundation.dart';

@immutable
class NoteModel {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime? updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.tags = const [],
    this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    DateTime? date;
    final rawDate = json['updatedAt'];
    if (rawDate is String && rawDate.isNotEmpty) {
      date = DateTime.tryParse(rawDate);
    }

    final tagsList = <String>[];
    if (json['tags'] is List) {
      for (final item in json['tags']) {
        final tag = item.toString().trim();
        if (tag.isNotEmpty) tagsList.add(tag);
      }
    }

    return NoteModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      tags: List.unmodifiable(tagsList),
      updatedAt: date,
    );
  }

  // Server strictly rejects unknown JSON keys on POST/PUT
  Map<String, dynamic> toPayloadJson() => {
    'title': title.trim(),
    'content': content.trim(),
    'tags': tags,
  };

  Map<String, dynamic> toFullJson() => {
    'id': id,
    'title': title,
    'content': content,
    'tags': tags,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedDate {
    if (updatedAt == null) return '';
    final dt = updatedAt!.toLocal();
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          listEquals(tags, other.tags) &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      tags.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() => 'NoteModel(id: $id, title: $title)';
}
