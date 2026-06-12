# RimLink

A LinkedIn-inspired professional networking mobile application built with Flutter and Supabase.

## Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Supabase account
- Android device/emulator

### Installation
```bash
git clone https://github.com/your-repo/rimlink.git
cd rimlink
flutter pub get
flutter run
```

### Configuration
Create `.env` file with Supabase credentials:
```
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
```

Set up Supabase: enable Email Authentication, import schema from `schema.sql`, configure RLS.

## Features
- **User Profiles**: Professional profiles with photos, banners, and status (Open to Work, Hiring, Providing Services)
- **Posts & Content**: Create, edit, like, and comment on posts
- **Networking**: Search users, send/accept/cancel connection requests, view network
- **Experience Management**: Add multiple work experiences with details
- **Education Management**: Add school, degree, field of study, dates and description
- **Job Listings**: Browse, post, edit, delete jobs with external apply links
- **Contact Info**: Share email/phone with per-field privacy controls
- **Authentication**: Secure login, registration, password reset

## Technologies
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Dependencies**: supabase_flutter, image_picker, cupertino_icons, url_launcher
- **UI**: Material Design

## Documentation
For comprehensive documentation, see [DOCUMENTATION.md](DOCUMENTATION.md)
