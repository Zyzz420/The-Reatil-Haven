# Flutter Client

This package hosts the Flutter rewrite of the Project Management Dashboard.  
It mirrors the original Next.js UX with:

- Auth-less dashboard shell with sidebar + top bar, dark/light theme toggle, and responsive layout
- Project analytics (charts), kanban board with drag & drop, list/table/timeline views, and creation dialogs
- Search, users, teams, timeline, priority, and settings pages backed by the existing Node/Prisma API

## Local development

```bash
flutter pub get
cp .env.example .env   # configure API_BASE_URL + DEFAULT_USER_ID
flutter run -d chrome  # or another supported device
```

The `.env` file is parsed via `flutter_dotenv` at startup.  
`DEFAULT_USER_ID` pre-selects a user for the priority page and navbar context switcher.

## Useful commands

- `flutter analyze` – static analysis (required to stay warning-free)
- `flutter test` – widget tests (currently a smoke test for the app shell)
- `flutter run -d chrome --web-renderer canvaskit` – closest to the original web build

## Project structure

- `lib/app.dart` – `ProjectManagementApp` root
- `lib/config/` – routing, theming, env config
- `lib/data/` – DTOs and `ApiService` (Dio wrapper)
- `lib/features/` – page-level UI modules
- `lib/state/` – Riverpod providers (UI + data)
- `lib/widgets/` – shared UI elements & dialogs
