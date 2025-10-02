class ValidationUtils {
  // Email validation
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Password validation
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    return password.length >= 6;
  }

  // Strong password validation
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;

    final hasUppercase = password.contains(RegExp('[A-Z]'));
    final hasLowercase = password.contains(RegExp('[a-z]'));
    final hasDigits = password.contains(RegExp('[0-9]'));
    final hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  // Name validation
  static bool isValidName(String name) {
    if (name.isEmpty) return false;
    return name.trim().length >= 2;
  }

  // Phone number validation
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  // Age validation
  static bool isValidAge(int? age) {
    if (age == null) return false;
    return age >= 3 && age <= 18;
  }

  // Form validation functions
  static String? validateEmailField(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!isValidEmail(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  static String? validatePasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (!isValidPassword(value)) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  static String? validateNameField(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    if (!isValidName(value)) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  static String? validateAgeField(String? value) {
    if (value == null || value.isEmpty) {
      return 'العمر مطلوب';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'العمر يجب أن يكون رقماً';
    }

    if (!isValidAge(age)) {
      return 'العمر يجب أن يكون بين 3 و 18 سنة';
    }
    return null;
  }

  // URL validation
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Arabic text validation
  static bool isValidArabicText(String text) {
    if (text.isEmpty) return false;

    final arabicRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
    return arabicRegex.hasMatch(text);
  }

  // English text validation
  static bool isValidEnglishText(String text) {
    if (text.isEmpty) return false;

    final englishRegex = RegExp(r'^[a-zA-Z\s]+$');
    return englishRegex.hasMatch(text);
  }

  // Word validation for learning app
  static bool isValidWord(String word) {
    if (word.isEmpty) return false;
    return word.trim().isNotEmpty && word.trim().length <= 50;
  }

  // Category validation
  static bool isValidCategory(String? category) {
    if (category == null || category.isEmpty) return false;

    final validCategories = [
      'objects',
      'animals',
      'colors',
      'numbers',
      'family',
      'food',
      'nature',
      'places',
      'actions',
      'emotions',
    ];

    return validCategories.contains(category);
  }

  // Difficulty level validation
  static bool isValidDifficultyLevel(int? level) {
    if (level == null) return false;
    return level >= 1 && level <= 5;
  }

  // File extension validation
  static bool isValidImageExtension(String filename) {
    if (filename.isEmpty) return false;

    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final extension = filename.toLowerCase().substring(
      filename.lastIndexOf('.'),
    );

    return validExtensions.contains(extension);
  }

  static bool isValidAudioExtension(String filename) {
    if (filename.isEmpty) return false;

    final validExtensions = ['.mp3', '.wav', '.aac', '.m4a'];
    final extension = filename.toLowerCase().substring(
      filename.lastIndexOf('.'),
    );

    return validExtensions.contains(extension);
  }

  // Text length validation
  static bool isValidTextLength(
    String text, {
    int minLength = 1,
    int maxLength = 255,
  }) {
    if (text.isEmpty) return minLength == 0;
    return text.length >= minLength && text.length <= maxLength;
  }

  // Number range validation
  static bool isInRange(num value, {required num min, required num max}) {
    return value >= min && value <= max;
  }

  // List validation
  static bool isValidList<T>(
    List<T>? list, {
    int minLength = 0,
    int? maxLength,
  }) {
    if (list == null) return minLength == 0;

    if (list.length < minLength) return false;
    if (maxLength != null && list.length > maxLength) return false;

    return true;
  }

  // Date validation
  static bool isValidDate(DateTime? date) {
    if (date == null) return false;

    final now = DateTime.now();
    final minDate = DateTime(1900);

    return date.isAfter(minDate) &&
        date.isBefore(now.add(const Duration(days: 365)));
  }

  // Future date validation
  static bool isValidFutureDate(DateTime? date) {
    if (date == null) return false;

    final now = DateTime.now();
    return date.isAfter(now);
  }

  // Past date validation
  static bool isValidPastDate(DateTime? date) {
    if (date == null) return false;

    final now = DateTime.now();
    return date.isBefore(now);
  }

  // Get validation error messages
  static String getEmailError(String email) {
    if (email.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!isValidEmail(email)) return 'البريد الإلكتروني غير صحيح';
    return '';
  }

  static String getPasswordError(String password) {
    if (password.isEmpty) return 'كلمة المرور مطلوبة';
    if (!isValidPassword(password)) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return '';
  }

  static String getNameError(String name) {
    if (name.isEmpty) return 'الاسم مطلوب';
    if (!isValidName(name)) return 'الاسم يجب أن يكون حرفين على الأقل';
    return '';
  }

  static String getAgeError(int? age) {
    if (age == null) return 'العمر مطلوب';
    if (!isValidAge(age)) return 'العمر يجب أن يكون بين 3 و 18 سنة';
    return '';
  }

  static String getWordError(String word, String language) {
    if (word.isEmpty) return 'الكلمة مطلوبة';
    if (!isValidWord(word)) return 'الكلمة يجب أن تكون بين 1 و 50 حرف';

    if (language == 'ar' && !isValidArabicText(word)) {
      return 'يجب أن تحتوي الكلمة العربية على أحرف عربية فقط';
    }

    if (language == 'en' && !isValidEnglishText(word)) {
      return 'يجب أن تحتوي الكلمة الإنجليزية على أحرف إنجليزية فقط';
    }

    return '';
  }

  static String getCategoryError(String? category) {
    if (category == null || category.isEmpty) return 'الفئة مطلوبة';
    if (!isValidCategory(category)) return 'الفئة غير صحيحة';
    return '';
  }

  static String getDifficultyLevelError(int? level) {
    if (level == null) return 'مستوى الصعوبة مطلوب';
    if (!isValidDifficultyLevel(level)) {
      return 'مستوى الصعوبة يجب أن يكون بين 1 و 5';
    }
    return '';
  }

  // Sanitize input
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Remove HTML tags
  static String removeHtmlTags(String input) {
    return input.replaceAll(RegExp('<[^>]*>'), '');
  }

  // Escape special characters
  static String escapeSpecialCharacters(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  // Validation getters for easy access
  static String get validateEmail => 'validation.emailInvalid';
  static String get validatePassword => 'validation.passwordRequired';
  static String get validateName => 'validation.nameRequired';
}
