class Validate {
  // RegEx pattern for validating email addresses.
  static String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static RegExp emailRegEx = RegExp(emailPattern);

  // Validates an email address.
  static bool isEmail(String value) {
    if (emailRegEx.hasMatch(value.trim())) {
      return true;
    }
    return false;
  }

  /*
   * Returns an error message if email does not validate.
   */
  static String? validateEmail(String value) {
    String email = value.trim();
    if (email.isEmpty) {
      return 'Email is required.';
    }
    if (!isEmail(email)) {
      return 'Valid email required.';
    }
    return null;
  }

  /*
   * Returns an error message if required field is empty.
   */
  static String? requiredField(String value) {
    if (value.trim().isEmpty) return "Password required";
    if (value.length < 6) return "Password must be at least 6 characters long";
    return null;
  }
}
