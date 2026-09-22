import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/note_model.dart';

abstract interface class NotesRepository {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> getNoteById(String id);
  Future<NoteModel> createNote({
    required String title,
    required String content,
    List<String> tags = const [],
  });
  Future<NoteModel> updateNote(
    String id, {
    required String title,
    required String content,
    List<String> tags = const [],
  });
}

class NotesRepositoryImpl implements NotesRepository {
  final DioClient _client;

  NotesRepositoryImpl({required DioClient dioClient}) : _client = dioClient;

  @override
  Future<List<NoteModel>> getNotes() async {
    final response = await _client.get(ApiConstants.notes);
    final data = response.data;

    if (data is Map && data['notes'] is List) {
      return (data['notes'] as List)
          .map(
            (item) =>
                NoteModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }
    if (data is List) {
      return data
          .map(
            (item) =>
                NoteModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    final response = await _client.get(ApiConstants.noteById(id));
    final data = response.data;

    if (data is Map<String, dynamic>) {
      if (data['note'] is Map<String, dynamic>) {
        return NoteModel.fromJson(data['note']);
      }
      return NoteModel.fromJson(data);
    }
    throw Exception('Invalid note format');
  }

  @override
  Future<NoteModel> createNote({
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    final response = await _client.post(
      ApiConstants.notes,
      data: {'title': title.trim(), 'content': content.trim(), 'tags': tags},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['note'] is Map<String, dynamic>) {
        return NoteModel.fromJson(data['note']);
      }
      return NoteModel.fromJson(data);
    }
    throw Exception('Failed to create note');
  }

  @override
  Future<NoteModel> updateNote(
    String id, {
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    final response = await _client.put(
      ApiConstants.noteById(id),
      data: {'title': title.trim(), 'content': content.trim(), 'tags': tags},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['note'] is Map<String, dynamic>) {
        return NoteModel.fromJson(data['note']);
      }
      return NoteModel.fromJson(data);
    }
    throw Exception('Failed to update note');
  }
}
