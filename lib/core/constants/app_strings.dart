// lib/core/constants/app_strings.dart

class AppStrings {
  AppStrings._();

  static const String appName = 'TuneMate';
  
  // Auth
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to connect with your mates';
  static const String emailLabel = 'Email Address';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String displayNameLabel = 'Display Name';
  static const String signInButton = 'Sign In';
  static const String registerButton = 'Register';
  static const String forgotPasswordLink = 'Forgot password?';
  static const String noAccountText = "Don't have an account? Register";
  static const String hasAccountText = 'Already have an account? Sign In';
  static const String forgotPasswordTitle = 'Reset Password';
  static const String forgotPasswordSubtitle = 'Enter your email to receive a password reset link';
  static const String sendResetLinkButton = 'Send Reset Link';
  static const String backToLoginLink = 'Back to login';
  static const String passwordTooWeak = 'Password is too weak';
  static const String passwordMatchError = 'Passwords do not match';

  // Conversations
  static const String conversationsTitle = 'Chats';
  static const String searchHint = 'Search...';
  static const String newGroup = 'New Group';
  static const String noConversations = 'No chats yet';
  static const String startChatting = 'Tap + to start messaging your friends';
  static const String deleteConfirmation = 'Are you sure you want to delete this chat?';
  
  // Call
  static const String incomingCall = 'Incoming Call';
  static const String accept = 'Accept';
  static const String decline = 'Decline';
  static const String activeCall = 'Active Call';
  static const String callEnded = 'Call ended';
}
