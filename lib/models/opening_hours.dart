class OpeningHours {
  final Map<int, List<TimeRange>> weekdayHours;
  final List<TimeRange> publicHolidayHours;
  final bool isAlwaysOpen;
  final bool isAlwaysClosed;

  OpeningHours({
    required this.weekdayHours,
    required this.publicHolidayHours,
    this.isAlwaysOpen = false,
    this.isAlwaysClosed = false,
  });

  static OpeningHours parse(String openingHoursString) {
    if (openingHoursString.isEmpty) {
      return OpeningHours(
        weekdayHours: {},
        publicHolidayHours: [],
        isAlwaysClosed: true,
      );
    }

    if (openingHoursString.toLowerCase().contains('24/7')) {
      return OpeningHours(
        weekdayHours: {},
        publicHolidayHours: [],
        isAlwaysOpen: true,
      );
    }

    Map<int, List<TimeRange>> weekdayHours = {};
    List<TimeRange> publicHolidayHours = [];

    List<String> rules = openingHoursString.split(';');

    for (String rule in rules) {
      rule = rule.trim();
      if (rule.isEmpty) continue;

      try {
        _parseRule(rule, weekdayHours, publicHolidayHours);
      } catch (e) {
        print('Error parsing opening hours rule: $rule - $e');
      }
    }

    return OpeningHours(
      weekdayHours: weekdayHours,
      publicHolidayHours: publicHolidayHours,
    );
  }

  static void _parseRule(String rule, Map<int, List<TimeRange>> weekdayHours,
      List<TimeRange> publicHolidayHours) {
    if (rule.toLowerCase().contains('off') ||
        rule.toLowerCase().contains('closed')) {
      return;
    }

    List<String> parts = rule.split(RegExp(r'\s+'));
    if (parts.length < 2) return;

    String daysPart = parts[0];
    String timePart = parts.sublist(1).join(' ');

    List<TimeRange> timeRanges = _parseTimeRanges(timePart);
    if (timeRanges.isEmpty) return;

    if (daysPart.contains('PH')) {
      publicHolidayHours.addAll(timeRanges);
      daysPart = daysPart.replaceAll('PH', '').replaceAll(',', '');
    }

    List<int> days = _parseDays(daysPart);
    for (int day in days) {
      weekdayHours[day] = (weekdayHours[day] ?? [])..addAll(timeRanges);
    }
  }

  static List<TimeRange> _parseTimeRanges(String timePart) {
    List<TimeRange> ranges = [];
    List<String> timeSlots = timePart.split(',');

    for (String slot in timeSlots) {
      slot = slot.trim();
      if (slot.contains('-')) {
        List<String> times = slot.split('-');
        if (times.length == 2) {
          TimeOfDay? start = _parseTime(times[0].trim());
          TimeOfDay? end = _parseTime(times[1].trim());
          if (start != null && end != null) {
            ranges.add(TimeRange(start: start, end: end));
          }
        }
      }
    }
    return ranges;
  }

  static List<int> _parseDays(String daysPart) {
    List<int> days = [];
    Map<String, int> dayMap = {
      'mo': 1, 'tu': 2, 'we': 3, 'th': 4, 'fr': 5, 'sa': 6, 'su': 7
    };

    daysPart = daysPart.toLowerCase().replaceAll(',', ' ');
    List<String> dayParts = daysPart.split(RegExp(r'\s+'));

    for (String part in dayParts) {
      part = part.trim();
      if (part.isEmpty) continue;

      if (part.contains('-')) {
        List<String> range = part.split('-');
        if (range.length == 2) {
          int? start = dayMap[range[0].trim()];
          int? end = dayMap[range[1].trim()];
          if (start != null && end != null) {
            for (int i = start; i <= end; i++) {
              days.add(i);
            }
          }
        }
      } else {
        int? day = dayMap[part];
        if (day != null) {
          days.add(day);
        }
      }
    }
    return days;
  }

  static TimeOfDay? _parseTime(String timeStr) {
    timeStr = timeStr.trim();
    RegExp timeRegex = RegExp(r'^(\d{1,2}):(\d{2})$');
    Match? match = timeRegex.firstMatch(timeStr);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  bool isOpenNow([DateTime? dateTime]) {
    dateTime ??= DateTime.now();
    if (isAlwaysOpen) return true;
    if (isAlwaysClosed) return false;

    int weekday = dateTime.weekday;
    TimeOfDay currentTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);

    List<TimeRange>? todayHours = weekdayHours[weekday];
    if (todayHours == null || todayHours.isEmpty) return false;

    for (TimeRange range in todayHours) {
      if (_isTimeInRange(currentTime, range)) {
        return true;
      }
    }
    return false;
  }

  bool _isTimeInRange(TimeOfDay time, TimeRange range) {
    int timeMinutes = time.hour * 60 + time.minute;
    int startMinutes = range.start.hour * 60 + range.start.minute;
    int endMinutes = range.end.hour * 60 + range.end.minute;

    if (endMinutes <= startMinutes) {
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  String getStatusText([DateTime? dateTime]) {
    if (isAlwaysOpen) return "Open 24/7";
    if (isAlwaysClosed) return "Closed";
    return isOpenNow(dateTime) ? "Open Now" : "Closed";
  }

  String getTodayHoursText([DateTime? dateTime]) {
    dateTime ??= DateTime.now();
    if (isAlwaysOpen) return "24 hours";
    if (isAlwaysClosed) return "Closed";

    List<TimeRange>? todayHours = weekdayHours[dateTime.weekday];
    if (todayHours == null || todayHours.isEmpty) {
      return "Closed today";
    }
    return todayHours.map((range) => "${_formatTime(range.start)} - ${_formatTime(range.end)}").join(", ");
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({required this.start, required this.end});

  @override
  String toString() {
    return "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }
}