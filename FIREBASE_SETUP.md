# Firebase Setup Guide for Notegram

This guide will walk you through setting up Firebase as the backend for your Notegram app.

## Prerequisites
- Flutter SDK installed
- Firebase account
- Web browser

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `notegram-app` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Click "Create project"

## Step 2: Enable Authentication

1. In Firebase project, click "Authentication" in left sidebar
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Click "Save"

## Step 3: Set up Firestore Database

1. Click "Firestore Database" in left sidebar
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select location closest to your users
5. Click "Enable"

## Step 4: Configure Firestore Security Rules

1. In Firestore Database, go to "Rules" tab
2. Replace default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own notes
    match /users/{userId}/notes/{noteId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public notes can be read by anyone, but only written by authenticated users
    match /public_notes/{noteId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User profiles can be read/written by the user themselves
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click "Publish"

## Step 5: Get Firebase Configuration

1. Click gear icon (⚙️) next to "Project Overview"
2. Select "Project settings"
3. Scroll to "Your apps" section
4. Click web icon (</>)
5. Register app with nickname: "notegram-web"
6. Copy the Firebase configuration object

## Step 6: Update Configuration Files

### Update `lib/firebase_options.dart`
Replace the placeholder values with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',
  appId: 'YOUR_ACTUAL_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
  projectId: 'YOUR_ACTUAL_PROJECT_ID',
  authDomain: 'YOUR_ACTUAL_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_ACTUAL_PROJECT_ID.appspot.com',
  measurementId: 'YOUR_ACTUAL_MEASUREMENT_ID',
);
```

### Update `web/index.html`
Replace the placeholder values in the script section:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_ACTUAL_API_KEY",
  authDomain: "YOUR_ACTUAL_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_ACTUAL_PROJECT_ID",
  storageBucket: "YOUR_ACTUAL_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_ACTUAL_SENDER_ID",
  appId: "YOUR_ACTUAL_APP_ID",
  measurementId: "YOUR_ACTUAL_MEASUREMENT_ID"
};
```

## Step 7: Install Dependencies

Run the following command to install Firebase dependencies:

```bash
flutter pub get
```

## Step 8: Test the App

1. Run the app:
```bash
flutter run -d chrome
```

2. Test user registration and login
3. Test creating, editing, and deleting notes
4. Verify notes appear in the correct tabs (Feed vs My Notes)

## Step 9: Security Considerations

### For Production:
1. Update Firestore rules to be more restrictive
2. Enable additional authentication methods if needed
3. Set up proper user roles and permissions
4. Consider implementing rate limiting

### Current Security Features:
- Users can only access their own notes
- Public notes are readable by everyone
- Only authenticated users can create/modify notes
- User data is isolated by UID

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized" error**
   - Ensure Firebase.initializeApp() is called in main()
   - Check that firebase_options.dart has correct values

2. **Authentication not working**
   - Verify Email/Password auth is enabled in Firebase Console
   - Check browser console for JavaScript errors

3. **Database operations failing**
   - Verify Firestore rules are published
   - Check that database is created and accessible

4. **CORS errors**
   - Ensure Firebase project domain is whitelisted
   - Check browser console for cross-origin issues

### Debug Mode:
- Use Flutter DevTools for debugging
- Check browser console for JavaScript errors
- Use Firebase Console to monitor database operations

## Next Steps

Once Firebase is working:
1. Add user profile management
2. Implement note sharing between users
3. Add real-time collaboration features
4. Set up push notifications
5. Add offline support with local caching

## Support

If you encounter issues:
1. Check Firebase documentation
2. Review Flutter Firebase plugin docs
3. Check GitHub issues for the Firebase Flutter plugins
4. Ensure all configuration values are correct

## Security Notes

⚠️ **Important**: Never commit your actual Firebase API keys to version control. Use environment variables or secure configuration management for production apps.
