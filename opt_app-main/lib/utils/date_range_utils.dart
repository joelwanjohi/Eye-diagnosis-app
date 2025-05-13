import 'package:flutter/material.dart';

class DateRangeUtils {
  /// Get date range for the current week
  static DateTimeRange getCurrentWeekRange() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final firstDayOfWeek = now.subtract(Duration(days: currentWeekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    
    return DateTimeRange(
      start: DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day),
      end: DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day, 23, 59, 59),
    );
  }

  /// Get date range for the last week
  static DateTimeRange getLastWeekRange() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final firstDayOfLastWeek = now.subtract(Duration(days: currentWeekday + 6));
    final lastDayOfLastWeek = firstDayOfLastWeek.add(const Duration(days: 6));
    
    return DateTimeRange(
      start: DateTime(firstDayOfLastWeek.year, firstDayOfLastWeek.month, firstDayOfLastWeek.day),
      end: DateTime(lastDayOfLastWeek.year, lastDayOfLastWeek.month, lastDayOfLastWeek.day, 23, 59, 59),
    );
  }

  /// Get date range for the current month
  static DateTimeRange getCurrentMonthRange() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = now.month < 12 ? DateTime(now.year, now.month + 1, 1) : DateTime(now.year + 1, 1, 1);
    final lastDayOfMonth = nextMonth.subtract(const Duration(days: 1));
    
    return DateTimeRange(
      start: firstDayOfMonth,
      end: DateTime(lastDayOfMonth.year, lastDayOfMonth.month, lastDayOfMonth.day, 23, 59, 59),
    );
  }

  /// Get date range for the last month
  static DateTimeRange getLastMonthRange() {
    final now = DateTime.now();
    final firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
    
    return DateTimeRange(
      start: firstDayOfLastMonth,
      end: DateTime(lastDayOfLastMonth.year, lastDayOfLastMonth.month, lastDayOfLastMonth.day, 23, 59, 59),
    );
  }

  /// Get date range for the last three months
  static DateTimeRange getLastThreeMonthsRange() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month - 2, 1);
    final lastDay = DateTime(now.year, now.month, now.day);
    
    return DateTimeRange(
      start: firstDay,
      end: DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59),
    );
  }

  /// Get date range for the last six months
  static DateTimeRange getLastSixMonthsRange() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month - 5, 1);
    final lastDay = DateTime(now.year, now.month, now.day);
    
    return DateTimeRange(
      start: firstDay,
      end: DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59),
    );
  }

  /// Get date range for the current year
  static DateTimeRange getCurrentYearRange() {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final lastDayOfYear = DateTime(now.year, 12, 31);
    
    return DateTimeRange(
      start: firstDayOfYear,
      end: DateTime(lastDayOfYear.year, lastDayOfYear.month, lastDayOfYear.day, 23, 59, 59),
    );
  }

  /// Format date range as string
  static String formatDateRange(DateTimeRange range) {
    return '${range.start.day}/${range.start.month}/${range.start.year} - '
        '${range.end.day}/${range.end.month}/${range.end.year}';
  }
}