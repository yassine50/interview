import 'package:flutter_test/flutter_test.dart';
import 'package:interview/data/models/note_model.dart';

void main() {
  group('NoteModel Serialization & Compliance', () {
    test('parses accurately from backend JSON response', () {
      final json = {
        'id': '1',
        'title': 'Mock interview preparation',
        'content': 'Review API design, HTTP semantics, and concurrency in Go.',
        'tags': ['interview', 'go'],
        'updatedAt': '2026-09-14T12:00:00Z',
      };

      final note = NoteModel.fromJson(json);

      expect(note.id, '1');
      expect(note.title, 'Mock interview preparation');
      expect(
        note.content,
        'Review API design, HTTP semantics, and concurrency in Go.',
      );
      expect(note.tags, ['interview', 'go']);
      expect(note.updatedAt, DateTime.parse('2026-09-14T12:00:00Z'));
    });

    test(
      'toPayloadJson strictly sends only title, content, and tags (no id, no updatedAt)',
      () {
        final note = NoteModel(
          id: '3',
          title: 'Interview note',
          content: 'Remember mutexes',
          tags: const ['go', 'interview'],
          updatedAt: DateTime.parse('2026-09-14T12:00:00Z'),
        );

        final payload = note.toPayloadJson();

        // Ensure NO unknown fields are present
        expect(payload.keys.toSet(), {'title', 'content', 'tags'});
        expect(payload['title'], 'Interview note');
        expect(payload['content'], 'Remember mutexes');
        expect(payload['tags'], ['go', 'interview']);
        expect(payload.containsKey('id'), isFalse);
        expect(payload.containsKey('updatedAt'), isFalse);
      },
    );

    test('handles missing or malformed tags gracefully', () {
      final json = {
        'id': '2',
        'title': 'Test note',
        'content': 'Some content',
        'tags': null,
      };

      final note = NoteModel.fromJson(json);
      expect(note.tags, isEmpty);
      expect(note.updatedAt, isNull);
    });
  });
}
