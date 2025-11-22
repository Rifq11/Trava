class ErrorFormatter {
  static String format(String error) {
    // exception
    String message = error.replaceFirst(RegExp(r'^Exception:\s*'), '');

    // error validation
    if (message.contains("Field validation for")) {
      final fieldMatch = RegExp(r"'(\w+)'").firstMatch(message);
      final errorMatch = RegExp(
        r"failed on the '(\w+)' tag",
      ).firstMatch(message);

      if (fieldMatch != null && errorMatch != null) {
        final fieldName = _formatFieldName(fieldMatch.group(1)!);
        final errorType = errorMatch.group(1)!;

        switch (errorType) {
          case 'email':
            return 'Please enter a valid email address';
          case 'required':
            return '$fieldName is required';
          case 'min':
            return '$fieldName is too short';
          case 'max':
            return '$fieldName is too long';
          default:
            return 'Invalid $fieldName';
        }
      }
    }

    if (message.contains("Key:")) {
      message = message.replaceAll(RegExp(r"Key:\s*'[^']*'\s*Error:\s*"), '');
    }

    // specific error
    if (message.toLowerCase().contains('email')) {
      if (message.toLowerCase().contains('validation')) {
        return 'Please enter a valid email address';
      }
      if (message.toLowerCase().contains('already') ||
          message.toLowerCase().contains('exists')) {
        return 'Email already registered';
      }
    }

    if (message.toLowerCase().contains('password')) {
      if (message.toLowerCase().contains('incorrect') ||
          message.toLowerCase().contains('wrong')) {
        return 'Incorrect password';
      }
      if (message.toLowerCase().contains('short') ||
          message.toLowerCase().contains('min')) {
        return 'Password must be at least 6 characters';
      }
    }

    if (message.toLowerCase().contains('unauthorized') ||
        message.toLowerCase().contains('invalid token')) {
      return 'Session expired. Please login again';
    }

    if (message.toLowerCase().contains('not found')) {
      return 'Resource not found';
    }

    return message.trim();
  }

  static String _formatFieldName(String field) {
    String formatted = field
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .trim();

    if (formatted.isNotEmpty) {
      formatted = formatted[0].toUpperCase() + formatted.substring(1);
    }

    return formatted;
  }
}
