class ModelMap {
  const ModelMap._();

  static String text(Map<dynamic, dynamic> map, String key,
      [String fallback = '']) {
    final value = map[key];
    return value is String ? value : fallback;
  }

  static int integer(Map<dynamic, dynamic> map, String key,
      [int fallback = 0]) {
    final value = map[key];
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double decimal(Map<dynamic, dynamic> map, String key,
      [double fallback = 0]) {
    final value = map[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool boolean(Map<dynamic, dynamic> map, String key,
      [bool fallback = false]) {
    final value = map[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return fallback;
  }

  static List<String> texts(Map<dynamic, dynamic> map, String key) {
    final value = map[key];
    if (value is! Iterable) return const [];
    return value.whereType<String>().toList();
  }

  static String date(Map<dynamic, dynamic> map, String key,
      [String fallback = '']) {
    final value = map[key];
    if (value is DateTime) return value.toIso8601String();
    if (value is! String) return fallback;
    return DateTime.tryParse(value)?.toIso8601String() ?? fallback;
  }
}