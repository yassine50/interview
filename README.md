# Notes App — Flutter REST API Client

A clean, responsive Flutter frontend application built with **Dio** to interact with the Notes REST API.

---

## Overview

This application serves as a complete client for the mock interview Notes API hosted at `https://backup.ssd4me.cloud`. It provides full CRUD operations, live search, tag filtering, responsive centered layouts, and error handling.

---

## Features

- **Full CRUD Support**:
  - **List Notes (`GET /api/notes`)**: Displays all notes with ID badges, timestamps, content previews, and tag chips.
  - **View Details (`GET /api/notes/{id}`)**: Bottom sheet displaying full note content, metadata, and expandable raw JSON inspection.
  - **Create Note (`POST /api/notes`)**: Modal form with validation for title and content, plus dynamic tag creation.
  - **Update Note (`PUT /api/notes/{id}`)**: Prefilled edit dialog to modify existing notes.
- **Strict API Compliance**: The backend rejects any unknown fields on `POST` and `PUT`. The `NoteModel.toPayloadJson()` strictly includes only `title`, `content`, and `tags`, omitting `id` and `updatedAt`.
- **Search & Tag Filtering**:
  - Instant filtering across title, content, and tags.
  - Horizontally scrollable tag filter chips.
- **Responsive Centered Layout**: All views and cards are constrained (`maxWidth: 750px`) and centered, providing an optimal reading experience on mobile, tablet, and desktop screens.
- **Network Resilience**:
  - 15-second timeouts for connect, receive, and send operations.
  - Friendly error states with a retry action.
  - HTTP logging interceptor for debugging in development.

---

## API Specification

- **Base URL**: `https://backup.ssd4me.cloud`
- **Content-Type**: `application/json`
- **Authentication**: None

### Endpoints

| Method | Endpoint | Description | Status Code |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/notes` | Returns list of all notes (`{"notes": [...]}`) | `200 OK` |
| `GET` | `/api/notes/{id}` | Returns a single note by string ID | `200 OK` / `404 Not Found` |
| `POST` | `/api/notes` | Creates a new note | `201 Created` / `400 Bad Request` |
| `PUT` | `/api/notes/{id}` | Replaces an existing note | `200 OK` / `400 Bad Request` / `404 Not Found` |

### Request Body (POST / PUT)

```json
{
  "title": "Interview note",
  "content": "Review Go concurrency and HTTP design",
  "tags": ["interview", "go"]
}
```

> **Note**: Both `title` and `content` are required and must not be blank. Unknown fields will cause the API to reject the request.

---

## Architecture & Codebase Structure

The project follows a clean separation of concerns:

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart       # Base URL, endpoints, timeouts, and headers
│   ├── errors/
│   │   └── api_exception.dart       # Maps DioException and backend errors to user messages
│   └── network/
│       ├── dio_client.dart          # Configured Dio instance with timeouts and helpers
│       └── logging_interceptor.dart # Concise request/response logging in debug mode
├── data/
│   ├── models/
│   │   └── note_model.dart          # Typed model with strict payload serialization
│   └── repositories/
│       └── notes_repository.dart    # Abstract interface and Dio implementation
├── state/
│   └── notes_controller.dart        # ChangeNotifier managing notes state, search, and filters
├── view/
│   ├── front.dart                   # Main dashboard with search, tag filters, and pull-to-refresh
│   └── widgets/
│       ├── note_card.dart           # Individual note card with tags and actions
│       ├── note_detail_sheet.dart   # Bottom sheet showing full note details and raw JSON
│       └── note_form_dialog.dart    # Create & edit modal form with validation
└── main.dart                        # Application entry point with Material 3 theming
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.7 or later)
- macOS, Linux, or Windows development environment

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd interview
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   # Run on connected device, simulator, or desktop
   flutter run
   ```

---

## Testing & Quality Checks

Run the automated test suite:
```bash
flutter test
```

Run static analysis:
```bash
flutter analyze
```

Format code:
```bash
dart format .
```

---

## Dependencies

- **[dio](https://pub.dev/packages/dio)** (`^5.11.1`): Powerful HTTP client for Dart with interceptors, global configuration, and timeout management.
- **flutter**: Material 3 components and design system.
