Map<String, Object>? toAnalyticsParams(Map<String, dynamic>? input) {
  if (input == null) return null;

  final result = <String, Object>{};

  for (final entry in input.entries) {
    final value = entry.value;

    if (value is String ||
        value is int ||
        value is double) {
      result[entry.key] = value;
    } else if (value is bool) {
      result[entry.key] = value ? 1 : 0; // Convert bool to int for Firebase
    } else {
      result[entry.key] = value.toString();
    }
  }

  return result;
}