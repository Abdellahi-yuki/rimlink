# RimLink

**A LinkedIn-inspired professional networking mobile application built with Flutter and Supabase.**

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Supabase account
- Android device/emulator

### Installation
```bash
# Clone the repository
git clone https://github.com/your-repo/rimlink.git
cd rimlink

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📱 Features
- **User Profiles**: Professional profiles with photos, banners, and status
- **Posts & Content**: Create, edit, like, and comment on posts
- **Networking**: Search users, send/accept connection requests
- **Experience Management**: Add multiple work experiences and education
- **Contact Info**: Share email/phone with privacy controls
- **Authentication**: Secure login and registration

## 🛠️ Technologies
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **State Management**: Provider
- **UI**: Material Design

## ⚙️ Configuration
1. Create `.env` file with Supabase credentials:
```
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
```

2. Set up Supabase:
- Enable Email Authentication
- Import database schema from `schema.sql`
- Configure Row Level Security (RLS)

## 📚 Documentation
For comprehensive documentation, see [DOCUMENTATION.md](DOCUMENTATION.md)

