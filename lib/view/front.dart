import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../data/models/note_model.dart';
import '../data/repositories/notes_repository.dart';
import '../state/notes_controller.dart';
import 'widgets/note_card.dart';
import 'widgets/note_detail_sheet.dart';
import 'widgets/note_form_dialog.dart';

class API extends StatefulWidget {
  final NotesController? customController;

  const API({super.key, this.customController});

  @override
  State<API> createState() => _APIState();
}

class _APIState extends State<API> {
  late final NotesController _controller;
  bool _searchOpen = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customController != null) {
      _controller = widget.customController!;
    } else {
      final client = DioClient();
      _controller = NotesController(
        repository: NotesRepositoryImpl(dioClient: client),
        dioClient: client,
      );
      _controller.loadNotes();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.customController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _createNote() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NoteFormDialog(
        onSubmit: ({required title, required content, tags = const []}) async {
          final ok = await _controller.createNote(
            title: title,
            content: content,
            tags: tags,
          );
          if (mounted) {
            _showSnack(
              ok
                  ? 'Note created'
                  : (_controller.errorMessage ?? 'Failed to create note'),
              isError: !ok,
            );
          }
          return ok;
        },
      ),
    );
  }

  void _editNote(NoteModel note) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NoteFormDialog(
        existingNote: note,
        onSubmit: ({required title, required content, tags = const []}) async {
          final ok = await _controller.updateNote(
            note.id,
            title: title,
            content: content,
            tags: tags,
          );
          if (mounted) {
            _showSnack(
              ok
                  ? 'Note updated'
                  : (_controller.errorMessage ?? 'Failed to update note'),
              isError: !ok,
            );
          }
          return ok;
        },
      ),
    );
  }

  void _openDetail(NoteModel note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          NoteDetailSheet(note: note, onEdit: () => _editNote(note)),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final notes = _controller.filteredNotes;
        final tags = _controller.availableTags;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Notes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: Icon(_searchOpen ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _searchOpen = !_searchOpen;
                    if (!_searchOpen) {
                      _searchController.clear();
                      _controller.setSearchQuery('');
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _controller.loadNotes,
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: Column(
                children: [
                  if (_searchOpen)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search notes or tags...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                        onChanged: _controller.setSearchQuery,
                      ),
                    ),
                  if (tags.isNotEmpty)
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: tags.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final tag = tags[i];
                          final selected = _controller.selectedTag == tag;
                          return FilterChip(
                            label: Text('#$tag'),
                            selected: selected,
                            onSelected: (_) => _controller.toggleTagFilter(tag),
                            visualDensity: VisualDensity.compact,
                          );
                        },
                      ),
                    ),
                  Expanded(child: _buildList(context, notes)),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _createNote,
            icon: const Icon(Icons.add),
            label: const Text('New Note'),
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<NoteModel> notes) {
    if (_controller.isLoading && notes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.status == NotesStatus.error && notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                _controller.errorMessage ?? 'Failed to connect to server',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                onPressed: _controller.loadNotes,
              ),
            ],
          ),
        ),
      );
    }

    if (notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notes, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                _searchController.text.isNotEmpty
                    ? 'No notes match your search'
                    : 'No notes yet',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _searchController.text.isNotEmpty
                    ? 'Try a different search term'
                    : 'Tap "New Note" to create one',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.loadNotes,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 84),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            key: ValueKey(note.id),
            note: note,
            onTap: () => _openDetail(note),
            onEdit: () => _editNote(note),
          );
        },
      ),
    );
  }
}
