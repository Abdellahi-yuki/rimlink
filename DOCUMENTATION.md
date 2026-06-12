# RimLink - LinkedIn-like Mobile Application

RimLink is a professional networking mobile application inspired by LinkedIn, designed for Android platforms. It provides users with the ability to connect, share posts, manage professional profiles, and build their professional network.

- **Package**: `com.rimlink.app`
- **Min SDK**: Android 21

## 📋 Table of Contents
- [Features](#-features)
- [Technologies Used](#-technologies-used)
- [Database Structure](#-database-structure)
- [Backend Functions](#-backend-functions)
- [Application Functions](#-application-functions)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Contributing](#-contributing)

---

## ✨ Features

### 👤 User Profiles
- Create and manage professional profiles
- Add personal information (name, title, location, about section)
- Upload profile pictures and banners
- Set professional status (Open to Work, Hiring, Providing Services)
- Connections count displayed on profile

### 📝 Posts & Content
- Create, edit, and delete posts
- Add images to posts
- Like and unlike posts
- Repost other users' posts (shows "X reposted" header with original author)
- Comment on posts with edit and delete support

### 💬 Comments System
- Add comments to posts
- Edit and delete your own comments
- View all comments on a post

### 🔍 Networking & Connections
- Search for other users by name or title
- Send and receive connection requests
- Cancel pending connection requests
- Accept or reject connection requests
- View your network connections
- View sent and received invitations

### 💼 Professional Experience
- Add and manage multiple work experiences
- Edit experience details (title, company, location, dates, description)
- Delete experience entries

### 🎓 Education
- Add and manage multiple education entries
- Record school, degree, field of study, start/end dates, description
- Edit and delete education entries

### 💼 Job Listings
- Browse job postings with company, location, description
- Post new jobs with title, company, location, description, apply link
- Edit and delete your own job postings
- Save jobs for later
- Open external apply links

### 📞 Contact Information
- Add and edit contact info (email, phone)
- View other users' contact information
- Per-field privacy controls (email public, phone public)

### 🔐 Authentication
- Secure user registration and login
- Password management
- Password reset via email
- Profile settings and preferences

---

## 📁 Project Structure

```
rimlink/
├── lib/
│   ├── main.dart                          # App entry point, MaterialApp, auth wrapper
│   ├── l10n/                              # Localization system (Flutter gen-l10n)
│   │   ├── app_en.arb                     # English strings (~190 keys)
│   │   ├── app_ar.arb                     # Arabic translations
│   │   ├── app_fr.arb                     # French translations
│   │   ├── app_localizations.dart         # Generated abstract class
│   │   ├── app_localizations_en.dart      # Generated English impl
│   │   ├── app_localizations_ar.dart      # Generated Arabic impl
│   │   └── app_localizations_fr.dart      # Generated French impl
│   ├── models/
│   │   └── data_models.dart               # ContactInfo, Experience, User, Comment, Post, Job
│   ├── data/
│   │   ├── locale_service.dart            # Singleton ChangeNotifier, persists locale to SharedPreferences
│   │   ├── supabase_service.dart          # All Supabase queries, mutations, RPC calls
│   │   └── mock_data.dart                 # Static mock data for development
│   └── ui/
│       ├── main_navigation.dart           # Bottom navigation bar (4 tabs)
│       ├── auth/
│       │   └── login_signup_page.dart     # Login/register screen with email+password
│       ├── feed/
│       │   ├── feed_page.dart             # Main feed — lists all posts chronologically
│       │   ├── create_post_page.dart      # Compose new post with image picker
│       │   ├── post_detail_page.dart      # Single post view with comments thread
│       │   └── search_page.dart           # Tabbed search (People / Posts) with results lists
│       ├── jobs/
│       │   ├── jobs_page.dart             # Job listings with search bar, filter, post dialog, job cards
│       │   └── job_detail_page.dart       # Single job view with edit, apply, save actions
│       ├── network/
│       │   ├── network_page.dart          # People suggestions, sent invites, connections list
│       │   └── invitations_page.dart      # Pending connection requests (accept/reject)
│       ├── profile/
│       │   ├── profile_page.dart          # Full profile view with sections (about, experience, education, skills, activity, open-to-work/hiring/services badges, contact info modal)
│       │   ├── settings_page.dart         # Settings menu (account prefs, security, sign out)
│       │   └── settings_subpages.dart     # AccountPreferencesPage, NameLocationIndustryPage, SecurityPage, EmailAddressesPage, ChangePasswordPage, VisibilityPage, NotificationsSettingsPage + language picker dialog
│       └── widgets/
│           ├── post_widget.dart           # Reusable post card (header, content, images, actions)
│           └── full_screen_image_viewer.dart  # Swipeable full-screen image gallery
├── test/
│   └── widget_test.dart                   # Smoke test for MaterialApp
├── android/                               # Android platform configuration
├── ios/                                   # iOS platform configuration
├── supabase/                              # SQL migrations
├── pubspec.yaml                           # Dependencies, version 1.1.0
├── l10n.yaml                              # gen-l10n config (arb-dir, template-arb-file)
├── analysis_options.yaml                  # Dart linter rules
├── flutter_launcher_icons.yaml           # App icon generation config
└── schema.sql                             # Full Supabase schema (tables, RLS, triggers, functions)
```

---

<section id="-widgets-and-pages">

## 📱 Widgets & Pages Reference

### Entry Point & Navigation

| File | Class | Type | Purpose | Key Methods/Props |
|---|---|---|---|---|
| `main.dart` | `RimlinkApp` | `StatefulWidget` | Root widget, holds `LocaleService`, configures `MaterialApp` with locale delegates | `locale` from `LocaleService`, `supportedLocales`, `localizationsDelegates` |
| `main.dart` | `AuthWrapper` | `StatefulWidget` | Checks auth state, routes to `MainNavigation` or `LoginSignupPage` | Listens to `onAuthStateChange` |
| `main_navigation.dart` | `MainNavigation` | `StatefulWidget` | 4-tab bottom navigation (`IndexedStack`): Feed, Network, Jobs, Profile | `_currentIndex`, `_onTabTapped(int)` |

### Auth

| File | Class | Purpose | Key Features |
|---|---|---|---|
| `login_signup_page.dart` | `LoginSignupPage` | Sign in / register toggle form | Email+password auth, full-name on signup, error display, loading state |

### Feed

| File | Class | Purpose | Key Methods |
|---|---|---|---|
| `feed_page.dart` | `FeedPage` | Chronological post list with pull-to-refresh | `_refreshPosts()`, `_showPostOptions(Post)`, `_navigateAndRefresh()` |
| `create_post_page.dart` | `CreatePostPage` | Compose post with optional images | `_pickImages()`, `_post()` — uses `image_picker`, uploads to Supabase Storage |
| `post_detail_page.dart` | `PostDetailPage` | Single post detail + comments thread | `_addComment()`, `_editCommentDialog(Comment)`, `_buildActionButton()` |
| `search_page.dart` | `SearchPage` | Tabbed search (People / Posts) | `_performSearch(String)`, `_buildUserResults()`, `_buildPostResults()` |

### Jobs

| File | Class | Purpose | Key Methods |
|---|---|---|---|
| `jobs_page.dart` | `JobsPage` | Job listings with search bar, saved filter, post dialog | `_loadJobs()`, `_searchQuery` filtering, `_showPostJobDialog()`, `_buildJobCard(Job)`, `_buildPillButton()` |
| `job_detail_page.dart` | `JobDetailPage` | View/edit/delete job, apply via URL, save toggle | `_editJob()`, `_applyForJob()`, `_toggleSave()` |

### Network

| File | Class | Purpose | Key Methods |
|---|---|---|---|
| `network_page.dart` | `NetworkPage` | People suggestions, sent invites, active connections | `_loadData()`, `_cancelInvitation(User)`, `_sendInvitation(User)`, `_buildFullUserCard()` |
| `invitations_page.dart` | `InvitationsPage` | Pending connection requests with accept/reject | `_respond(requesterId, status)` |

### Profile

| File | Class | Purpose | Key Methods |
|---|---|---|---|
| `profile_page.dart` | `ProfilePage` | Full profile: banner/avatar, contact info, about, experience, education, skills, activity, open-to-work/hiring/services | `_loadProfile()`, `_saveProfile()`, `_pickAndUploadImage(bool isAvatar)`, `_editFieldDialog()`, `_editContactInfoDialog()`, `_showOpenToModal()`, `_showAddSectionModal()`, `_editExperienceDialog()`, `_editEducationDialog()`, `_showContactInfoModal()`, `_showPostOptions()`, `_buildBadgeBanner()` |
| `settings_page.dart` | `SettingsPage` | Settings menu with account prefs, security, sign out | `_buildSettingTile()` |
| `settings_subpages.dart` | `AccountPreferencesPage` | Name/location/industry editing + language picker | Routes to `NameLocationIndustryPage`, shows language dialog |
| | `NameLocationIndustryPage` | Edit name, location, industry fields | `_loadProfile()`, `_save()` |
| | `SecurityPage` | Account access section (email, password) | Routes to `EmailAddressesPage`, `ChangePasswordPage` |
| | `EmailAddressesPage` | View primary email, placeholder for add-email | Shows current auth email |
| | `ChangePasswordPage` | Change password form with validation | `_save()` validates match + min length, calls Supabase |
| | `VisibilityPage` | *(placeholder)* Profile visibility settings | N/A |
| | `NotificationsSettingsPage` | *(placeholder)* Notification preferences | N/A |

### Shared Widgets

| File | Class | Purpose | Props |
|---|---|---|---|
| `post_widget.dart` | `PostWidget` | Reusable post card with header, content, images, stats, action buttons | `post`, `onTap`, `onProfileTap`, `onMenuPressed`, `onRepost`, `showMenu` |
| `full_screen_image_viewer.dart` | `FullScreenImageViewer` | Swipeable image gallery with page indicator | `imageUrls`, `initialIndex` |

---

<section id="-localization">

## 🌐 Localization System

RimLink supports **3 languages** with Flutter's built-in `gen-l10n` tool:

| Language | Code | File |
|---|---|---|
| English | `en` | `lib/l10n/app_en.arb` |
| Arabic (RTL) | `ar` | `lib/l10n/app_ar.arb` |
| French | `fr` | `lib/l10n/app_fr.arb` |

### Architecture

1. **Source of truth**: `.arb` files in `lib/l10n/` — each key has an English value, with `@key` blocks for descriptions and plural placeholders
2. **Code generation**: Run `flutter gen-l10n` to produce `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_ar.dart`, `app_localizations_fr.dart`
3. **Usage**: `AppLocalizations.of(context)!.someKey` in all widgets; plural methods accept `int` args (e.g., `connectionCount(5)`)
4. **Locale persistence**: `LocaleService` (singleton `ChangeNotifier`) saves the language code to `SharedPreferences` and calls `notifyListeners()`; `RimlinkApp` listens and rebuilds `MaterialApp` with the new `locale`
5. **Language picker**: `_showLanguagePicker()` dialog in `settings_subpages.dart` with radio buttons for English / العربية / Français

### Adding a new locale
1. Create `app_xx.arb` in `lib/l10n/` with all keys
2. Add `"xx"` label key to all ARB files
3. Run `flutter gen-l10n`
4. Add the option to the language picker dialog in `settings_subpages.dart`

---

<section id="-state-management">

## ⚡ State Management

The app uses **built-in Flutter state management** (no external libraries):

- **`setState`** in every `StatefulWidget` for local UI state (loading, form values, search query, etc.)
- **`LocaleService`** (extends `ChangeNotifier`) for global locale state — singleton accessed via `LocaleService.instance` or `LocaleService()` factory; `RimlinkApp` subscribes via `addListener`
- **No Provider, Riverpod, Bloc, or Redux** — state is intentionally kept simple and widget-local

---

<section id="-supabase-service">

## 🔌 SupabaseService API Reference

(`lib/data/supabase_service.dart`) — all database operations go through this class.

### Auth
- `currentAuthUser` — returns `sb.User?`
- `currentUserId` — returns `String?`
- `changePassword(String newPassword)` — calls `supabase.auth.updateUser()`

### Profile
- `getCurrentUserProfile()` — `SELECT * FROM profiles WHERE id = auth.uid()`
- `getProfileById(String id)` — `SELECT * FROM profiles WHERE id = $id` (with nested contact_info)
- `updateProfile(User user)` — `UPDATE profiles SET ... WHERE id = $id`
- `updateProfileField(String field, String value)` — update single column
- `uploadImage(String path, List<int> bytes)` — upload to `rimlink` storage bucket, return public URL

### Experience
- `getExperiences(String userId)` → `List<Map>`
- `addExperience(userId, data)`, `updateExperience(id, data)`, `deleteExperience(id)`

### Education
- `getEducations(String userId)` → `List<Map>`
- `addEducation(userId, data)`, `updateEducation(id, data)`, `deleteEducation(id)`

### Posts
- `getPosts()` — joins `author`, `post_likes`, `reposted_post` with nested `original_author`
- `createPost(content, {imageUrls})` — `INSERT INTO posts`
- `repostPost(postId)` — creates a new post with `repost_of_id` referencing original
- `getUserPosts(userId)`, `updatePostContent(id, content)`, `deletePost(id)`
- `toggleLike(postId, currentlyLiked)` — upsert/delete `post_likes` + call `increment_likes`/`decrement_likes` RPC
- `searchPosts(query)` — `ILIKE '%query%'` on content

### Comments
- `getComments(postId)` — joins `author` profile
- `addComment(postId, content)`, `updateComment(commentId, content)` (via RPC `update_comment_content`), `deleteComment(commentId)`

### Network
- `searchUsers(String query)` — `ILIKE` match on name or title
- `sendConnectionRequest(targetId)` — `INSERT INTO connections (requester_id, receiver_id, status='pending')`
- `cancelConnectionRequest(targetId)` — `DELETE` pending request
- `respondToConnectionRequest(requesterId, status)` — `UPDATE connections SET status` (accept/reject)
- `getConnectionStatus(targetUserId)` → `'sent'`, `'received'`, `'accepted'`, or `null`
- `getConnections()` — all accepted connections (both sides)
- `getPendingInvitations()` — requests where current user is receiver
- `getSentInvitations()` — requests where current user is requester
- `getPeopleYouMayKnow()` — profiles not connected and not self, excluding those with pending requests

### Jobs
- `getJobs()` → `List<Map>` — all jobs ordered by newest
- `postJob(data)`, `updateJob(id, data)`, `deleteJob(id)`
- `getSavedJobIds()` → `List<String>` — IDs of jobs saved by current user
- `toggleSaveJob(jobId, currentlySaved)` — upsert/delete `saved_jobs`

### Contact Info
- `getContactInfo(userId)` → `Map?` — email, phone, is_email_public, is_phone_public
- `updateContactInfo(userId, data)` — `UPSERT` on `contact_info`

---

<section id="-models">

## 📦 Data Models (`lib/models/data_models.dart`)

| Model | Fields | Notes |
|---|---|---|
| `ContactInfo` | `email`, `phone` | Simple two-field model for contact_info table |
| `Experience` | `id`, `title`, `company`, `location`, `startDate`, `endDate?`, `description` | `fromMap` maps `start_date`/`end_date` snake_case |
| `User` | `id`, `name`, `title`, `location`, `about`, `experience`, `education`, `skills`, `connections`, `isOpenToWork`, `isHiring`, `isProvidingServices`, `avatarUrl?`, `bannerUrl?`, `email?`, `phone?` | Has `copyWith()` for immutable updates |
| `Comment` | `id`, `author` (User), `content`, `createdAt` | `timeAgo` getter: `Now` / `5m` / `3h` / `2d` / `1w` |
| `Post` | `id`, `author`, `createdAt`, `content`, `likesCount`, `isLiked`, `commentsCount`, `imageUrls`, `repostOfId?`, `originalAuthor?`, `originalContent?`, `originalImageUrls` | `fromMap` handles repost join, comments aggregate |
| `Job` | `id`, `title`, `company`, `location`, `description`, `isEasyApply`, `isPromoted`, `applyLink`, `posterId`, `createdAt` | `timeAgo`: `Just now` / `5h ago` / `3d ago` |

---

## 🛠️ Technologies Used

### Frontend
- **Framework**: Flutter (Dart 3.x)
- **UI Components**: Flutter Material Design
- **Image Handling**: image_picker, Network Image

### Backend
- **Database & Authentication**: Supabase (PostgreSQL with RLS)
- **API**: supabase_flutter (Supabase Client for Dart)
- **Storage**: Supabase Storage for images

### Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| flutter | SDK | UI framework |
| supabase_flutter | ^2.12.4 | Supabase client (auth, database, storage, realtime) |
| image_picker | ^1.1.2 | Camera/gallery image selection |
| url_launcher | (transitive via supabase_flutter) | Open external URLs (job apply links) |
| cupertino_icons | ^1.0.8 | iOS-style icons |
| flutter_lints | ^6.0.0 (dev) | Lint rules |

### Development Tools
- **IDE**: Android Studio / VS Code
- **Version Control**: Git
- **Build System**: Gradle

### Deployment
- **Platform**: Android
- **Distribution**: APK

---

## 🗃️ Database Structure

### Tables

#### `profiles`
Stores user profile information.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | User ID (matches auth.users) | PRIMARY KEY, REFERENCES auth.users(id) |
| name | TEXT | User's full name | NOT NULL |
| title | TEXT | Professional title | |
| location | TEXT | User's location | |
| about | TEXT | About/bio section | |
| education | TEXT | Education history (legacy) | |
| skills | TEXT | User's skills | |
| is_open_to_work | BOOLEAN | Job-seeking status | DEFAULT false |
| is_hiring | BOOLEAN | Recruiter status | DEFAULT false |
| is_providing_services | BOOLEAN | Freelancer status | DEFAULT false |
| created_at | TIMESTAMP | Profile creation date | DEFAULT now() |
| avatar_url | TEXT | Profile picture URL | |
| banner_url | TEXT | Profile banner URL | |
| connections | INTEGER | Auto-counted accepted connections | DEFAULT 0 |

#### `contact_info`
Stores user contact information with privacy controls.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Record ID | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| user_id | UUID | User ID (references profiles) | REFERENCES profiles(id), UNIQUE |
| email | TEXT | User's email address | |
| phone | TEXT | User's phone number | |
| is_email_public | BOOLEAN | Email visibility | DEFAULT false |
| is_phone_public | BOOLEAN | Phone visibility | DEFAULT false |
| created_at | TIMESTAMP | Record creation date | DEFAULT now() |

#### `experiences`
Stores professional experience entries.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Experience ID | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| user_id | UUID | User ID (references profiles) | REFERENCES profiles(id) ON DELETE CASCADE |
| title | TEXT | Job title | NOT NULL |
| company | TEXT | Company name | NOT NULL |
| location | TEXT | Job location | |
| start_date | TEXT | Start date (e.g., "Jan 2020") | NOT NULL |
| end_date | TEXT | End date (optional) | |
| description | TEXT | Job description | |
| created_at | TIMESTAMP | Record creation date | DEFAULT now() |

#### `educations`
Stores user education entries.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Education ID | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| user_id | UUID | User ID (references profiles) | REFERENCES profiles(id) ON DELETE CASCADE |
| school | TEXT | School/institution name | NOT NULL |
| degree | TEXT | Degree obtained | |
| field_of_study | TEXT | Field of study/major | |
| start_date | TEXT | Start date (e.g., "Sep 2016") | NOT NULL |
| end_date | TEXT | End date (optional) | |
| description | TEXT | Additional details | |
| created_at | TIMESTAMP | Record creation date | DEFAULT now() |

#### `posts`
Stores user posts and content.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Post ID | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| author_id | UUID | User ID of post author | REFERENCES profiles(id) ON DELETE CASCADE |
| content | TEXT | Post content | NOT NULL |
| likes_count | INTEGER | Number of likes | DEFAULT 0 |
| created_at | TIMESTAMP | Post creation date | DEFAULT now() |
| image_urls | TEXT[] | Array of image URLs | DEFAULT '{}' |
| repost_of_id | UUID | Original post ID if repost | REFERENCES posts(id) ON DELETE SET NULL |

#### `comments`
Stores comments on posts.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Comment ID | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| post_id | UUID | Post ID | REFERENCES posts(id) ON DELETE CASCADE |
| author_id | UUID | User ID of comment author | REFERENCES profiles(id) ON DELETE CASCADE |
| content | TEXT | Comment content | NOT NULL |
| created_at | TIMESTAMP | Comment creation date | DEFAULT now() |

#### `post_likes`
Tracks post likes (many-to-many relationship).

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| post_id | UUID | Post ID | REFERENCES posts(id) ON DELETE CASCADE, PRIMARY KEY |
| user_id | UUID | User ID | REFERENCES profiles(id) ON DELETE CASCADE, PRIMARY KEY |
| created_at | TIMESTAMP | Like creation date | DEFAULT now() |

#### `connections`
Manages user connections/network.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Connection ID | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| requester_id | UUID | User ID who sent the request | REFERENCES profiles(id) ON DELETE CASCADE |
| receiver_id | UUID | User ID who received the request | REFERENCES profiles(id) ON DELETE CASCADE |
| status | TEXT | Connection status | DEFAULT 'pending', CHECK (status IN ('pending', 'accepted', 'rejected')) |
| created_at | TIMESTAMP | Request creation date | DEFAULT now() |

**RLS Policies:**
- `SELECT` — Users can see their own connections (requester or receiver)
- `INSERT` — Only the requester can send connection requests
- `UPDATE` — Only the receiver can accept/reject requests
- `DELETE` — Only the requester can cancel their own pending requests

#### `jobs`
Stores job listings.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Job ID | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| poster_id | UUID | User ID who posted the job | REFERENCES profiles(id) ON DELETE CASCADE |
| title | TEXT | Job title | NOT NULL |
| company | TEXT | Company name | NOT NULL |
| location | TEXT | Job location | |
| description | TEXT | Job description | |
| apply_link | TEXT | External URL to apply | |
| is_promoted | BOOLEAN | Promoted job status | DEFAULT false |
| is_easy_apply | BOOLEAN | Easy apply status | DEFAULT false |
| created_at | TIMESTAMP | Job creation date | DEFAULT now() |

#### `saved_jobs`
Tracks jobs saved by users.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| user_id | UUID | User ID | REFERENCES profiles(id) ON DELETE CASCADE, PRIMARY KEY |
| job_id | UUID | Job ID | REFERENCES jobs(id) ON DELETE CASCADE, PRIMARY KEY |
| created_at | TIMESTAMP | Save date | DEFAULT now() |

---

## 🔧 Backend Functions

### PostgreSQL Functions

#### `update_comment_content(comment_id uuid, new_content text, user_id uuid)`
Updates the content of a comment if the user owns it.

```sql
CREATE OR REPLACE FUNCTION public.update_comment_content(
  comment_id uuid,
  new_content text,
  user_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.comments
    WHERE id = comment_id AND author_id = user_id
  ) THEN
    RAISE EXCEPTION 'User does not own this comment';
  END IF;
  
  UPDATE public.comments
  SET content = new_content
  WHERE id = comment_id;
END;
$$;
```

#### `increment_likes(post_id uuid)`
Increments the like count for a post.

```sql
CREATE OR REPLACE FUNCTION public.increment_likes(post_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE posts
  SET likes_count = likes_count + 1
  WHERE id = post_id;
END;
$$;
```

#### `decrement_likes(post_id uuid)`
Decrements the like count for a post.

```sql
CREATE OR REPLACE FUNCTION public.decrement_likes(post_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE posts
  SET likes_count = likes_count - 1
  WHERE id = post_id;
END;
$$;
```

#### `handle_new_user()`
Trigger function to create a profile when a new user signs up.

#### `update_connections_count()`
Trigger function to auto-update the `connections` count on the `profiles` table when connection requests are accepted, rejected, or deleted.

```sql
CREATE OR REPLACE FUNCTION public.update_connections_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'accepted' THEN
    UPDATE public.profiles SET connections = connections + 1 WHERE id = NEW.requester_id;
    UPDATE public.profiles SET connections = connections + 1 WHERE id = NEW.receiver_id;
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status != 'accepted' AND NEW.status = 'accepted' THEN
      UPDATE public.profiles SET connections = connections + 1 WHERE id = NEW.requester_id;
      UPDATE public.profiles SET connections = connections + 1 WHERE id = NEW.receiver_id;
    ELSIF OLD.status = 'accepted' AND NEW.status != 'accepted' THEN
      UPDATE public.profiles SET connections = connections - 1 WHERE id = NEW.requester_id;
      UPDATE public.profiles SET connections = connections - 1 WHERE id = NEW.receiver_id;
    END IF;
  ELSIF TG_OP = 'DELETE' AND OLD.status = 'accepted' THEN
    UPDATE public.profiles SET connections = connections - 1 WHERE id = OLD.requester_id;
    UPDATE public.profiles SET connections = connections - 1 WHERE id = OLD.receiver_id;
  END IF;
  RETURN NULL;
END;
$$;
```

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.profiles (id, name, title, location)
  VALUES (new.id, new.raw_user_meta_data->>'name', 'New Member', 'Not set');
  RETURN new;
END;
$$;
```

---

## 📱 Application Functions

### Authentication
- `signInWithEmail(email, password)` - Sign in with email and password
- `signUpWithEmail(email, password, name)` - Register a new user
- `signOut()` - Sign out the current user
- `resetPassword(email)` - Send password reset email

### Profile Management
- `getCurrentUserProfile()` - Get the current user's profile
- `getProfileById(userId)` - Get a user profile by ID
- `updateProfile(user)` - Update user profile
- `updateProfileField(field, value)` - Update a single profile field
- `uploadImage(path, bytes)` - Upload an image to storage

### Contact Information
- `getContactInfo(userId)` - Get contact info for a user
- `updateContactInfo(userId, contactData)` - Update contact info

### Experience Management
- `addExperience(userId, experienceData)` - Add new experience
- `getExperiences(userId)` - Get all experiences for a user
- `updateExperience(experienceId, experienceData)` - Update an experience
- `deleteExperience(experienceId)` - Delete an experience

### Education Management
- `addEducation(userId, educationData)` - Add new education entry
- `getEducations(userId)` - Get all education entries for a user
- `updateEducation(educationId, educationData)` - Update an education entry
- `deleteEducation(educationId)` - Delete an education entry

### Posts
- `createPost(content, imageUrls)` - Create a new post
- `getPosts()` - Get all posts (with pagination)
- `getUserPosts(userId)` - Get posts by a specific user
- `updatePostContent(postId, content)` - Update post content
- `deletePost(postId)` - Delete a post
- `repostPost(postId)` - Repost an existing post (creates new post with repost_of_id reference)
- `toggleLike(postId, currentlyLiked)` - Like/unlike a post

### Comments
- `getComments(postId)` - Get all comments for a post
- `addComment(postId, content)` - Add a comment to a post
- `updateComment(commentId, content)` - Update a comment
- `deleteComment(commentId)` - Delete a comment

### Networking
- `searchUsers(query)` - Search for users by name or title
- `searchPosts(query)` - Search for posts by content
- `sendConnectionRequest(targetUserId)` - Send a connection request
- `cancelConnectionRequest(targetUserId)` - Cancel a connection request
- `respondToConnectionRequest(requesterId, status)` - Accept/reject a request
- `getConnectionStatus(targetUserId)` - Check connection status
- `getConnections()` - Get all accepted connections
- `getPendingInvitations()` - Get pending connection requests
- `getSentInvitations()` - Get sent connection requests
- `getPeopleYouMayKnow()` - Get suggested connections

### Jobs
- `getJobs()` - Get all job listings
- `postJob(jobData)` - Create a new job listing
- `updateJob(jobId, jobData)` - Update a job listing
- `deleteJob(jobId)` - Delete a job listing
- `getSavedJobIds()` - Get IDs of saved jobs
- `toggleSaveJob(jobId, currentlySaved)` - Save/unsave a job

---

## 🚀 Installation

### Prerequisites
- Flutter SDK (version 3.0 or higher)
- Android Studio / VS Code with Flutter plugin
- Supabase account and project
- Android device or emulator

### Setup Instructions

1. **Clone the repository**
```bash
 git clone https://github.com/your-repo/rimlink.git
 cd rimlink
```

2. **Install dependencies**
```bash
 flutter pub get
```

3. **Configure Supabase**
- Create a `.env` file in the project root
- Add your Supabase credentials:
```
 SUPABASE_URL=your-supabase-project-url
 SUPABASE_ANON_KEY=your-supabase-anon-key
```

4. **Set up the database**
- Run the SQL scripts from the `schema.sql` file in Supabase SQL Editor
- Apply any additional functions from the [Backend Functions](#-backend-functions) section

5. **Run the app**
```bash
 flutter run
```

---

## ⚙️ Configuration

### Supabase Setup
1. Create a new project in Supabase
2. Enable Email Authentication in Authentication → Providers
3. Set up Storage for image uploads
4. Configure Row Level Security (RLS) policies
5. Import the database schema from `schema.sql`

### Environment Variables
Create a `.env` file in the project root:

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Build Configuration

Android configuration is in `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    applicationId = "com.rimlink.app"
    minSdk = 21
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}
```

### App Icons

Icons are generated from `icon.png` using `flutter_launcher_icons`. To regenerate:

```bash
dart run flutter_launcher_icons
```

Configuration is in `flutter_launcher_icons.yaml`.

### Migrations

Database migrations are in `supabase/migrations/`. Apply them in order via the Supabase SQL editor.

---

## Code Style
- Follow Dart/Flutter style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

