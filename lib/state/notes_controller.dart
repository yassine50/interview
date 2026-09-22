import 'package:flutter/foundation.dart';
import '../core/errors/api_exception.dart';
import '../core/network/dio_client.dart';
import '../data/models/note_model.dart';
import '../data/repositories/notes_repository.dart';

enum NotesStatus { initial, loading, success, error }

class NotesController extends ChangeNotifier {
  final NotesRepository _repository;
  final DioClient _dioClient;

  NotesStatus _status = NotesStatus.initial;
  String? _errorMessage;
  List<NoteModel> _notes = [];
  String _searchQuery = '';
  String? _selectedTag;
  bool _isSubmitting = false;

  NotesController({
    required NotesRepository repository,
    required DioClient dioClient,
  }) : _repository = repository,
       _dioClient = dioClient;

  NotesStatus get status => _status;
  bool get isLoading => _status == NotesStatus.loading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedTag => _selectedTag;
  String get currentBaseUrl => _dioClient.baseUrl;

  List<NoteModel> get allNotes => List.unmodifiable(_notes);

  List<NoteModel> get filteredNotes {
    if (_searchQuery.isEmpty && _selectedTag == null) return _notes;

    final query = _searchQuery.toLowerCase();
    return _notes.where((note) {
      final matchesSearch =
          query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.tags.any((t) => t.toLowerCase().contains(query));

      final matchesTag =
          _selectedTag == null || note.tags.contains(_selectedTag);
      return matchesSearch && matchesTag;
    }).toList();
  }

  List<String> get availableTags {
    final tags = <String>{};
    for (final note in _notes) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void toggleTagFilter(String tag) {
    _selectedTag = _selectedTag == tag ? null : tag;
    notifyListeners();
  }

  Future<void> updateBaseUrl(String newUrl) async {
    _dioClient.updateBaseUrl(newUrl);
    notifyListeners();
    await loadNotes();
  }

  Future<void> loadNotes() async {
    _status = NotesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _notes = await _repository.getNotes();
      _status = NotesStatus.success;
    } on ApiException catch (e) {
      _status = NotesStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = NotesStatus.error;
      _errorMessage = 'Failed to load notes: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createNote({
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final note = await _repository.createNote(
        title: title,
        content: content,
        tags: tags,
      );
      _notes = [note, ..._notes];
      _status = NotesStatus.success;
      _errorMessage = null;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create note: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNote(
    String id, {
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final updated = await _repository.updateNote(
        id,
        title: title,
        content: content,
        tags: tags,
      );

      final index = _notes.indexWhere((n) => n.id == id);
      if (index != -1) {
        final list = List<NoteModel>.from(_notes);
        list[index] = updated;
        _notes = list;
      }

      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update note: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
