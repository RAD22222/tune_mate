// lib/core/extensions/datetime_extensions.dart

import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return DateFormat('E').format(this); // Mon, Tue, etc.
    } else {
      return DateFormat('MMM d').format(this); // Dec 12, Jan 5, etc.
    }
  }

  String toMessageTime() {
    return DateFormat('h:mm a').format(this);
  }

  String toMessageDateSeparator() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(year, month, day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(this);
    }
  }
}
