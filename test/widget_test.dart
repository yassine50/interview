import 'package:flutter_test/flutter_test.dart';
import 'package:interview/core/network/dio_client.dart';
import 'package:interview/main.dart';
import 'package:interview/state/notes_controller.dart';

import 'notes_controller_test.dart';

void main() {
  testWidgets('App renders Notes REST API view smoke test', (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeNotesRepository();
    final dioClient = DioClient(baseUrl: 'https://notes.example.com');
    final controller = NotesController(
      repository: fakeRepo,
      dioClient: dioClient,
    );

    // Initial load
    await controller.loadNotes();

    await tester.pumpWidget(MyApp(customController: controller));
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('Notes'), findsOneWidget);

    // Verify notes from fake repository are rendered
    expect(find.text('Mock interview preparation'), findsOneWidget);
    expect(find.text('Flutter UI architecture'), findsOneWidget);

    // Verify New Note button exists
    expect(find.text('New Note'), findsOneWidget);
  });
}
