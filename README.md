# RimLink

A LinkedIn-inspired professional networking mobile application built with Flutter & Supabase.

- **Package**: `com.rimlink.app`
- **Min SDK**: Android 21
- **Version**: `1.1.0`

## Quick Start

```bash
git clone https://github.com/your-repo/rimlink.git
cd rimlink
flutter pub get
flutter run
```

Requires a Supabase project — see [DOCUMENTATION.md](DOCUMENTATION.md#-configuration) for full setup.

## Features

- **Profiles** — banner/avatar, about, status badges (Open to Work / Hiring / Services), contact info with privacy controls
- **Posts** — create with images, edit, delete, like, repost, comment thread
- **Network** — people suggestions, send/accept/cancel connections, view network
- **Jobs** — browse with search bar, post/edit/delete, save for later, easy apply
- **Experience & Education** — multiple entries with full CRUD
- **Settings** — account prefs (name/location/title), security (email, password change), sign out
- **Localization** — English, Arabic (RTL), French; language picker in settings
- **Authentication** — email/password sign up, sign in, password reset

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart 3.x, Material Design) |
| Backend | Supabase (PostgreSQL, Auth, Storage, RPC) |
| Key packages | `supabase_flutter`, `image_picker`, `url_launcher`, `shared_preferences`, `intl`, `flutter_localizations` |
| State mgmt | `setState` + `LocaleService` (singleton `ChangeNotifier`) |
| Models | 6 classes (`User`, `Post`, `Comment`, `Job`, `Experience`, `ContactInfo`) with `fromMap`/`toMap` serialization |

## Regenerating Icons

```bash
dart run flutter_launcher_icons
```

## Documentation

For comprehensive documentation covering architecture, widget reference, database schema, API reference, localization, and RLS policies, see **[DOCUMENTATION.md](DOCUMENTATION.md)**.
