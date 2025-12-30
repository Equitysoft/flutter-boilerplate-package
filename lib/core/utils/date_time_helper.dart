import 'package:intl/intl.dart';

/// Date & Time Helper - Common date/time utilities
///
/// Usage:
/// ```dart
/// DateTimeHelper.formatDate(DateTime.now()) // "30-12-2025"
/// DateTimeHelper.formatTime(DateTime.now()) // "10:30 AM"
/// DateTimeHelper.isToday(someDate) // true/false
/// ```
class DateTimeHelper {
  DateTimeHelper._();

  // ==================== DATE FORMATS ====================

  /// Format: dd-MM-yyyy (e.g., "30-12-2025")
  static String formatDate(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// Format: yyyy-MM-dd (API format, e.g., "2025-12-30")
  static String formatDateApi(DateTime? date, {String fallback = ''}) {
    if (date == null) return fallback;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format: dd MMM yyyy (e.g., "30 Dec 2025")
  static String formatDateShort(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format: dd MMMM yyyy (e.g., "30 December 2025")
  static String formatDateFull(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('dd MMMM yyyy').format(date);
  }

  /// Format: EEEE, dd MMMM yyyy (e.g., "Monday, 30 December 2025")
  static String formatDateWithDay(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('EEEE, dd MMMM yyyy').format(date);
  }

  // ==================== TIME FORMATS ====================

  /// Format: hh:mm a (e.g., "10:30 AM")
  static String formatTime(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('hh:mm a').format(date);
  }

  /// Format: HH:mm (24-hour, e.g., "22:30")
  static String formatTime24(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('HH:mm').format(date);
  }

  /// Format: hh:mm:ss a (e.g., "10:30:45 AM")
  static String formatTimeWithSeconds(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('hh:mm:ss a').format(date);
  }

  // ==================== DATE & TIME COMBINED ====================

  /// Format: dd-MM-yyyy hh:mm a (e.g., "30-12-2025 10:30 AM")
  static String formatDateTime(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('dd-MM-yyyy hh:mm a').format(date);
  }

  /// Format: dd MMM yyyy, hh:mm a (e.g., "30 Dec 2025, 10:30 AM")
  static String formatDateTimeShort(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  // ==================== TODAY / YESTERDAY CHECKS ====================

  /// Check if date is today
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime? date) {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime? date) {
    if (date == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Get relative date string (Today, Yesterday, or formatted date)
  static String getRelativeDate(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    if (isTomorrow(date)) return 'Tomorrow';
    return formatDateShort(date);
  }

  /// Get relative date with time
  static String getRelativeDateWithTime(
    DateTime? date, {
    String fallback = '-',
  }) {
    if (date == null) return fallback;
    final time = formatTime(date);
    if (isToday(date)) return 'Today, $time';
    if (isYesterday(date)) return 'Yesterday, $time';
    if (isTomorrow(date)) return 'Tomorrow, $time';
    return '${formatDateShort(date)}, $time';
  }

  // ==================== WEEK HELPERS ====================

  /// Get start of current week (Monday)
  static DateTime get startOfWeek {
    final now = DateTime.now();
    final weekday = now.weekday;
    return DateTime(now.year, now.month, now.day - (weekday - 1));
  }

  /// Get end of current week (Sunday)
  static DateTime get endOfWeek {
    final now = DateTime.now();
    final weekday = now.weekday;
    return DateTime(now.year, now.month, now.day + (7 - weekday), 23, 59, 59);
  }

  /// Get start of week for a specific date
  static DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Get end of week for a specific date
  static DateTime getEndOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(
      date.year,
      date.month,
      date.day + (7 - weekday),
      23,
      59,
      59,
    );
  }

  // ==================== MONTH HELPERS ====================

  /// Get start of current month
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Get end of current month
  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  /// Get start of month for a specific date
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month for a specific date
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  // ==================== YEAR HELPERS ====================

  /// Get start of current year
  static DateTime get startOfYear {
    final now = DateTime.now();
    return DateTime(now.year, 1, 1);
  }

  /// Get end of current year
  static DateTime get endOfYear {
    final now = DateTime.now();
    return DateTime(now.year, 12, 31, 23, 59, 59);
  }

  // ==================== DAY HELPERS ====================

  /// Get start of day
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // ==================== DIFFERENCE HELPERS ====================

  /// Get difference in days
  static int getDaysDifference(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Get time ago string (e.g., "2 hours ago", "3 days ago")
  static String getTimeAgo(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // ==================== PARSING HELPERS ====================

  /// Parse date from string (dd-MM-yyyy)
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat('dd-MM-yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse date from API format (yyyy-MM-dd)
  static DateTime? parseDateApi(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse ISO 8601 date
  static DateTime? parseIso(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // ==================== UTILITY ====================

  /// Get month name
  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2024, month));
  }

  /// Get short month name
  static String getMonthNameShort(int month) {
    return DateFormat('MMM').format(DateTime(2024, month));
  }

  /// Get day name
  static String getDayName(int weekday) {
    return DateFormat('EEEE').format(DateTime(2024, 1, weekday));
  }

  /// Get short day name
  static String getDayNameShort(int weekday) {
    return DateFormat('EEE').format(DateTime(2024, 1, weekday));
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get age from date of birth
  static int getAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
