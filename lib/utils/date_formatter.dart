import 'package:intl/intl.dart';

class DateFormatter {
  static String formatISOToLocal(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('MMM dd, yyyy - HH:mm').format(date);
    } catch (e) {
      return isoString;
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateWithTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(date);
  }

  static String formatDateForFiltering(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return isoString;
    }
  }

  static String getRelativeTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} years ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return isoString;
    }
  }
}