You are a senior Flutter developer. Build a production-ready mobile chat application frontend for Android (with iOS compatibility) using the following stack and specifications.

---

## Tech stack

- Flutter (Dart) — Android-first
- Material 3 (Material You) design system
- Riverpod (state management, code-gen flavour with @riverpod annotations)
- GoRouter (navigation with deep linking support)
- sqflite (local SQLite storage)
- flutter_secure_storage (token and key storage)

---

## Project structure

lib/
├── main.dart
├── app.dart                  # MaterialApp.router + GoRouter setup
├── core/
│   ├── constants/            # app_colors.dart, app_strings.dart, app_sizes.dart
│   ├── extensions/           # DateTime, String, BuildContext helpers
│   ├── utils/                # formatters, debouncer, validators
│   └── widgets/              # shared: avatar, loading_indicator, error_view
├── features/
│   ├── auth/
│   │   ├── data/             # auth_repository.dart, auth_remote_datasource.dart
│   │   ├── domain/           # user.dart (model), auth_state.dart
│   │   └── presentation/
│   │       ├── providers/    # auth_provider.dart (Riverpod)
│   │       └── screens/      # login_screen.dart, register_screen.dart, forgot_password_screen.dart
│   ├── conversations/
│   │   ├── data/
│   │   ├── domain/           # conversation.dart, message.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       └── screens/      # conversations_list_screen.dart, new_conversation_screen.dart
│   ├── chat/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/      # chat_screen.dart
│   │       └── widgets/
│   │           ├── message_bubble.dart
│   │           ├── message_input.dart
│   │           ├── attachment_picker.dart
│   │           ├── voice_note_recorder.dart
│   │           ├── gif_picker.dart
│   │           └── emoji_picker_sheet.dart
│   ├── calling/
│   │   ├── domain/           # call.dart, call_state.dart
│   │   └── presentation/
│   │       ├── providers/    # call_provider.dart
│   │       └── screens/      # incoming_call_screen.dart, active_call_screen.dart
│   ├── profile/
│   │   └── presentation/
│   │       └── screens/      # profile_screen.dart, edit_profile_screen.dart, settings_screen.dart
│   └── contacts/
│       └── presentation/
│           └── screens/      # contacts_screen.dart, add_contact_screen.dart
└── services/
    ├── local_db/             # database_service.dart, message_dao.dart, settings_dao.dart
    └── notification/         # notification_service.dart (FCM stub)

---

## Navigation (GoRouter)

Routes and their GoRouter path/name:

/                     → redirect to /conversations (if authed) or /login
/login                → LoginScreen
/register             → RegisterScreen
/forgot-password      → ForgotPasswordScreen
/conversations        → ConversationsListScreen (shell route)
/conversations/new    → NewConversationScreen
/chat/:conversationId → ChatScreen
/profile              → ProfileScreen
/profile/edit         → EditProfileScreen
/settings             → SettingsScreen
/contacts             → ContactsScreen
/call/incoming        → IncomingCallScreen
/call/active/:callId  → ActiveCallScreen

Use GoRouter's redirect guard: if the user is unauthenticated, redirect any protected route to /login.
Use ShellRoute for the bottom navigation bar (Conversations, Contacts, Profile).

---

## Screens — detailed UI specs

### Auth screens
- LoginScreen: email + password TextFormFields, "Forgot password?" link, Sign in button, "Don't have an account? Register" link. No social logins needed now.
- RegisterScreen: display name, email, password, confirm password. Show password strength indicator.
- ForgotPasswordScreen: single email field, send reset link button, back to login link.

### ConversationsListScreen
- AppBar with search icon and overflow menu (Settings, New group).
- FAB to start a new conversation.
- ListView of ConversationTile: avatar, name, last message preview (truncated 1 line), timestamp (relative: "just now", "2h", "Mon"), unread count badge (filled circle, primary color), online indicator dot (green).
- Empty state illustration when no conversations.
- Pull-to-refresh.
- Swipe-to-delete with confirmation.

### ChatScreen
- AppBar: back arrow, avatar + name + online/typing status, video call icon, voice call icon, overflow menu.
- MessageList (reversed ListView): date separators ("Today", "Yesterday", "Dec 12"), own messages right-aligned (primary color bubble), other messages left-aligned (surface color bubble).
- Each MessageBubble shows: text or media preview, timestamp, read receipt icons (sent ✓, delivered ✓✓, read ✓✓ in primary color).
- Message types to support: text, image (thumbnail + tap to fullscreen), video (thumbnail + play icon), file (icon + filename + size), voice note (waveform bar + duration + play/pause), GIF (animated), emoji-only (larger font size for 1-3 emoji messages).
- Long-press bubble to show context menu: Reply, Copy, Forward, React (emoji row), Delete.
- Reply preview strip above input when replying.
- MessageInput bar: emoji button (opens emoji picker bottom sheet), text field (expandable, max 5 lines), paperclip attachment button (opens modal bottom sheet with: Camera, Gallery, File, Voice note, GIF), send button (replaces mic icon when text is present), mic button for voice note recording.
- Voice note recording UI: waveform animation, recording duration, swipe-left to cancel, send button.

### IncomingCallScreen
- Full screen with caller avatar (large), name, call type badge (Voice / Video).
- Two large circular buttons: Decline (red), Accept (green).
- Subtle ripple/pulse animation behind the avatar.

### ActiveCallScreen
- Full screen dark UI.
- Video call: local video PiP (bottom right corner, draggable), remote video fills screen.
- Voice call: large avatar centered on a blurred/gradient background.
- Controls row (bottom): mute mic, toggle camera, flip camera, end call (red), speaker, add participant.
- Call duration timer (top).
- Swipe up to reveal: emoji reactions row, chat during call button.

### ProfileScreen / EditProfileScreen
- Avatar with edit overlay, display name, status message, phone/email.
- Edit mode: inline editing with save/cancel in AppBar.

### SettingsScreen
- Sections: Account, Notifications (toggle per type), Privacy, Storage & Data (clear cache button), About.

---

## Riverpod providers to scaffold

authStateProvider         — stream of current User? from Supabase auth (stub)
conversationsProvider     — AsyncNotifier<List<Conversation>>
chatProvider(String convId) — AsyncNotifier<List<Message>>
typingIndicatorProvider(String convId) — StreamProvider<List<String>> (user ids typing)
onlineStatusProvider(String userId) — StreamProvider<bool>
callProvider              — StateNotifier<CallState>
replyTargetProvider       — StateProvider<Message?>
recordingStateProvider    — StateNotifier<RecordingState>

---

## Data models (Dart)

class User {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? statusMessage;
  final DateTime? lastSeen;
  final bool isOnline;
}

class Conversation {
  final String id;
  final ConversationType type; // direct, group
  final String name;
  final String? avatarUrl;
  final Message? lastMessage;
  final int unreadCount;
  final List<String> memberIds;
  final DateTime updatedAt;
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final MessageType type; // text, image, video, file, audio, gif, emoji
  final String? content;
  final String? fileUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSizeBytes;
  final int? audioDurationMs;
  final Message? replyTo;
  final MessageStatus status; // sending, sent, delivered, read, failed
  final List<MessageReaction> reactions;
  final DateTime createdAt;
}

class Call {
  final String id;
  final String callerId;
  final String calleeId;
  final CallType type; // voice, video
  final CallStatus status; // ringing, active, ended, missed, declined
  final DateTime? startedAt;
  final int? durationSeconds;
}

---

## SQLite local schema (sqflite)

messages table:
  id TEXT PK, conversation_id TEXT, sender_id TEXT, type TEXT,
  content TEXT, file_url TEXT, status TEXT, created_at INTEGER,
  synced INTEGER DEFAULT 0

conversations table:
  id TEXT PK, name TEXT, type TEXT, last_message_id TEXT,
  unread_count INTEGER DEFAULT 0, updated_at INTEGER

settings table:
  key TEXT PK, value TEXT

cached_media table:
  url TEXT PK, local_path TEXT, cached_at INTEGER, size_bytes INTEGER

---

## Design system

Use Material 3 (Material You). Define a custom ColorScheme using ColorScheme.fromSeed() with the app's primary seed color (#6750A4 or brand color of choice).

Theming rules:
- Use Theme.of(context) everywhere, no hardcoded colors.
- Support light and dark mode from the start.
- Custom text styles: define in AppTextStyles extending M3 typescale.
- Border radius: 12dp for message bubbles, 16dp for input bars, 24dp for full-screen sheets.
- Own message bubble: primaryContainer color, no border.
- Other message bubble: surfaceVariant color, no border.
- Elevation: use M3 tonal elevation (not shadows).

---

## Packages to use (pubspec.yaml)

dependencies:
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  go_router: ^14.x
  sqflite: ^2.x
  path_provider: ^2.x
  flutter_secure_storage: ^9.x
  image_picker: ^1.x
  file_picker: ^8.x
  camera: ^0.10.x
  emoji_picker_flutter: ^2.x
  record: ^5.x          # voice notes
  audioplayers: ^6.x    # voice note playback
  cached_network_image: ^3.x
  intl: ^0.19.x
  timeago: ^3.x
  uuid: ^4.x
  permission_handler: ^11.x
  dio: ^5.x             # HTTP client for Tenor GIF API
  shimmer: ^3.x         # loading placeholders
  flutter_slidable: ^3.x # swipeable list items

dev_dependencies:
  riverpod_generator: ^2.x
  build_runner: ^2.x
  freezed: ^2.x
  json_serializable: ^6.x

---

## What to stub (backend connections)

All Supabase calls should be behind a repository interface with a FakeRepository implementation for now:
- Return hardcoded mock data (3-5 conversations, 10-15 messages each).
- Simulate async delays with Future.delayed(Duration(milliseconds: 800)).
- Simulate realtime with a periodic timer that appends a new mock message every 15 seconds.

WebRTC and FCM should be empty service stubs with TODO comments.

---

## Code quality requirements

- Use freezed for all data models (copyWith, equality, toJson/fromJson).
- Use riverpod_generator (@riverpod annotations) everywhere.
- All async operations must handle loading, data, and error states via AsyncValue.
- Separate concerns: no business logic in widgets.
- Use const constructors wherever possible.
- All text must use l10n-ready strings (AppStrings class for now, arb later).
- No print() statements; use debugPrint() or a logger.
- Every screen must have a corresponding loading skeleton (use Shimmer package).

---

## Deliverable

Generate the complete Flutter project file by file. Start with:
1. pubspec.yaml
2. lib/main.dart
3. lib/app.dart (GoRouter + MaterialApp.router)
4. lib/core/ (constants, extensions, shared widgets)
5. Feature by feature, data model → provider → screen → widgets

For each file, output the full file path as a comment on line 1, then the complete Dart code. Do not truncate. Do not use placeholder comments like "// ... rest of implementation". Write every line.