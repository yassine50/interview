import 'package:flutter_test/flutter_test.dart';
import 'package:interview/core/network/dio_client.dart';
import 'package:interview/data/models/note_model.dart';
import 'package:interview/data/repositories/notes_repository.dart';
import 'package:interview/state/notes_controller.dart';

class FakeNotesRepository implements NotesRepository {
  List<NoteModel> notes = [
    const NoteModel(
      id: '1',
      title: 'Mock interview preparation',
      content: 'Review Go concurrency',
      tags: ['interview', 'go'],
    ),
    const NoteModel(
      id: '2',
      title: 'Flutter UI architecture',
      content: 'Master widgets and Dio networking',
      tags: ['flutter', 'architecture'],
    ),
  ];

  @override
  Future<List<NoteModel>> getNotes() async => List.from(notes);

  @override
  Future<NoteModel> getNoteById(String id) async =>
      notes.firstWhere((n) => n.id == id);

  @override
  Future<NoteModel> createNote({
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    final newNote = NoteModel(
      id: '${notes.length + 1}',
      title: title,
      content: content,
      tags: tags,
      updatedAt: DateTime.now(),
    );
    notes.insert(0, newNote);
    return newNote;
  }

  @override
  Future<NoteModel> updateNote(
    String id, {
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    final index = notes.indexWhere((n) => n.id == id);
    final updated = NoteModel(
      id: id,
      title: title,
      content: content,
      tags: tags,
      updatedAt: DateTime.now(),
    );
    notes[index] = updated;
    return updated;
  }
}

void main() {
  group('NotesController', () {
    late FakeNotesRepository repository;
    late DioClient dioClient;
    late NotesController controller;

    setUp(() {
      repository = FakeNotesRepository();
      dioClient = DioClient(baseUrl: 'https://test.example.com');
      controller = NotesController(
        repository: repository,
        dioClient: dioClient,
      );
    });

    test('initial status and successful notes loading', () async {
      expect(controller.status, NotesStatus.initial);
      await controller.loadNotes();
      expect(controller.status, NotesStatus.success);
      expect(controller.allNotes.length, 2);
    });

    test('search query filters notes accurately', () async {
      await controller.loadNotes();
      controller.setSearchQuery('concurrency');
      expect(controller.filteredNotes.length, 1);
      expect(controller.filteredNotes.first.id, '1');

      controller.setSearchQuery('flutter');
      expect(controller.filteredNotes.length, 1);
      expect(controller.filteredNotes.first.id, '2');
    });

    test('tag selection filters notes', () async {
      await controller.loadNotes();
      controller.toggleTagFilter('go');
      expect(controller.filteredNotes.length, 1);
      expect(controller.selectedTag, 'go');

      // Toggling same tag unselects it
      controller.toggleTagFilter('go');
      expect(controller.selectedTag, isNull);
      expect(controller.filteredNotes.length, 2);
    });

    test('creates note and prepends it to list', () async {
      await controller.loadNotes();
      final success = await controller.createNote(
        title: 'New Note',
        content: 'Testing creation',
        tags: ['test'],
      );

      expect(success, isTrue);
      expect(controller.allNotes.length, 3);
      expect(controller.allNotes.first.title, 'New Note');
    });

    test('updates existing note in list', () async {
      await controller.loadNotes();
      final success = await controller.updateNote(
        '1',
        title: 'Updated Title',
        content: 'Updated Content',
        tags: ['updated'],
      );

      expect(success, isTrue);
      final note1 = controller.allNotes.firstWhere((n) => n.id == '1');
      expect(note1.title, 'Updated Title');
      expect(note1.tags, ['updated']);
    });
  });
}
