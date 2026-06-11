# RimLink - LinkedIn-like Mobile Application

RimLink is a professional networking mobile application inspired by LinkedIn, designed for Android platforms. It provides users with the ability to connect, share posts, manage professional profiles, and build their professional network.

![RimLink Logo](https://via.placeholder.com/150x150?text=RimLink+Logo)

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

### 📝 Posts & Content
- Create, edit, and delete posts
- Add images to posts
- Like and comment on posts
- View post details and comments

### 💬 Comments System
- Add comments to posts
- Edit and delete your own comments
- View all comments on a post

### 🔍 Networking & Connections
- Search for other users by name or title
- Send and receive connection requests
- Accept or reject connection requests
- View your network connections

### 💼 Professional Experience
- Add and manage multiple work experiences
- Edit experience details (title, company, location, dates, description)
- Add education, skills, and other profile sections

### 📞 Contact Information
- Add and edit contact info (email, phone)
- View other users' contact information
- Control visibility of contact details

### 🔐 Authentication
- Secure user registration and login
- Password management
- Profile settings and preferences

---

## 🛠️ Technologies Used

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Provider (built-in Flutter state management)
- **UI Components**: Flutter Material Design
- **Image Handling**: Image Picker, Network Image

### Backend
- **Database & Authentication**: Supabase (PostgreSQL)
- **API**: Supabase Client for Dart
- **Storage**: Supabase Storage for images

### Development Tools
- **IDE**: Android Studio / VS Code
- **Version Control**: Git
- **Build System**: Gradle
- **CI/CD**: GitHub Actions (optional)

### Deployment
- **Platform**: Android
- **Distribution**: APK, Play Store (future)

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
| education | TEXT | Education history | |
| skills | TEXT | User's skills | |
| is_open_to_work | BOOLEAN | Job-seeking status | DEFAULT false |
| is_hiring | BOOLEAN | Recruiter status | DEFAULT false |
| is_providing_services | BOOLEAN | Freelancer status | DEFAULT false |
| created_at | TIMESTAMP | Profile creation date | DEFAULT now() |
| avatar_url | TEXT | Profile picture URL | |
| banner_url | TEXT | Profile banner URL | |

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

#### `jobs`
Stores job listings.

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| id | UUID | Job ID | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| title | TEXT | Job title | NOT NULL |
| company | TEXT | Company name | NOT NULL |
| location | TEXT | Job location | |
| description | TEXT | Job description | |
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

### Posts
- `createPost(content, imageUrls)` - Create a new post
- `getPosts()` - Get all posts (with pagination)
- `getUserPosts(userId)` - Get posts by a specific user
- `updatePostContent(postId, content)` - Update post content
- `deletePost(postId)` - Delete a post
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
Update `android/app/build.gradle` with your application details:

```gradle
android {
    defaultConfig {
        applicationId "com.example.rimlink"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
    }
}
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

### Code Style
- Follow Dart/Flutter style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

