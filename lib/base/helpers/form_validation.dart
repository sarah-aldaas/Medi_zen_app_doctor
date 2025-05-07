class FormValidation {
  static String? notEmpty(String value) {
    if (value.isEmpty) {
      return 'Email field is required.';
    }
    return null;
  }

  static String? emailValidation(String value) {
    if (value.isEmpty) {
      return 'Email field is required.';
    } else if (!_isValidEmail(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? passwordValidation(String value) {
    if (value.isEmpty) {
      return 'Password field is required.';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    return null;
  }

  static String? confirmPasswordValidation(String confirmValue, String passValue) {
    if (confirmValue.isEmpty) {
      return 'Confirm Password field is required.';
    } else if (passValue != confirmValue) {
      return 'Passwords not match.';
    }
    return null;
  }

  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }
}
