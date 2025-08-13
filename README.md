## Notegram

A simple, cross‑platform notes app built with Flutter and Firebase. Users can create private notes, share public notes to the community feed, and interact using upvotes, downvotes, and saves. The app supports light/dark themes with a user‑controlled toggle in the profile.

### Features
- **Authentication**: Email/password sign in/out (Firebase Auth)
- **My Notes**: Create, edit, delete private notes
- **Public Feed**: View public notes from all users
- **Voting**: Toggle upvote/downvote per user (one active vote at a time)
- **Save to My Notes**: Toggle save/unsave public notes into your private notes
- **Themes**:
  - Light by default on Get Started/Login
  - Gradient background across the app
  - Dark mode (black/blue gradient) toggle available in Profile
- **Profile**: Profile details, theme settings, About section (Version 1.0.0, Under Development), and Logout
- **Default Landing After Login**: App opens on the My Notes tab with a one‑time welcome dialog

### Tech stack
- **Flutter** (Material 3 components)
- **Firebase**: Authentication, Cloud Firestore
 - **GitHub**: Repository hosting and version control (link to be added)


### Project structure (key files)
- `lib/main.dart`: App entry, themes, routing
- `lib/home_page.dart`: Tabs (Feed / My Notes / Profile) and layout
- `lib/my_notes_tab.dart`: Private notes list
- `lib/feed_tab.dart`: Public notes feed (vote/save actions)
- `lib/profile_screen.dart`: Profile UI with theme toggle and About
- `lib/services/`:
  - `firebase_auth_service.dart`: Auth helpers
  - `firestore_service.dart`: Notes CRUD, voting, and save/unsave
  - `theme_provider.dart`: Theme mode + gradient management

### Setup
1. Install Flutter and configure your target platforms.
2. Create a Firebase project and enable Authentication and Firestore.
3. Configure FlutterFire to generate `lib/firebase_options.dart` or replace the existing file with your project’s settings.
4. Review `FIREBASE_SETUP.md` for additional details.
5. Install dependencies:
   - `flutter pub get`

### Run
```
flutter run
```

### Notes
- Theme switching is available in the Profile tab. Get Started and Login remain light for consistent branding.
- Users can vote once per note (upvote or downvote). Tapping the active vote removes it.
- Saving a public note adds a private copy to “My Notes”; tapping again removes it.

### Attribution
-Developed using Cursor AI that managed the codebase throughout development.
