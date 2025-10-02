import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  late FlutterTts _flutterTts;
  bool _isInitialized = false;

  // TTS Settings
  double _speechRate = 0.5;
  double _speechVolume = 1;
  double _speechPitch = 1;
  String _language = 'ar-SA';

  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    // Set up TTS handlers
    _flutterTts.setStartHandler(() {
      print('TTS Started');
    });

    _flutterTts.setCompletionHandler(() {
      print('TTS Completed');
    });

    _flutterTts.setProgressHandler((
      String text,
      int startOffset,
      int endOffset,
      String word,
    ) {
      print('TTS Progress: $word');
    });

    _flutterTts.setErrorHandler((msg) {
      print('TTS Error: $msg');
    });

    // Set default settings
    await _setDefaultSettings();

    _isInitialized = true;
  }

  Future<void> _setDefaultSettings() async {
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_speechVolume);
    await _flutterTts.setPitch(_speechPitch);
    await _flutterTts.setLanguage(_language);
  }

  // Speak text
  Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) await initialize();

    if (language != null) {
      await setLanguage(language);
    }

    await _flutterTts.speak(text);
  }

  // Speak Arabic text
  Future<void> speakArabic(String text) async {
    await speak(text, language: 'ar-SA');
  }

  // Speak English text
  Future<void> speakEnglish(String text) async {
    await speak(text, language: 'en-US');
  }

  // Stop speaking
  Future<void> stop() async {
    if (!_isInitialized) return;
    await _flutterTts.stop();
  }

  // Pause speaking
  Future<void> pause() async {
    if (!_isInitialized) return;
    await _flutterTts.pause();
  }

  // Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) await initialize();
    _speechRate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  // Set speech volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) await initialize();
    _speechVolume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_speechVolume);
  }

  // Set speech pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) await initialize();
    _speechPitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_speechPitch);
  }

  // Set language
  Future<void> setLanguage(String language) async {
    if (!_isInitialized) await initialize();
    _language = language;
    await _flutterTts.setLanguage(_language);
  }

  // Get available languages
  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) await initialize();
    final languages = await _flutterTts.getLanguages;
    if (languages is List) {
      return languages.cast<String>();
    }
    return [];
  }

  // Get available voices
  Future<List<Map<String, String>>> getAvailableVoices() async {
    if (!_isInitialized) await initialize();
    final voices = await _flutterTts.getVoices;
    if (voices is List) {
      return voices.cast<Map<String, String>>();
    }
    return [];
  }

  // Set voice
  Future<void> setVoice(Map<String, String> voice) async {
    if (!_isInitialized) await initialize();
    await _flutterTts.setVoice(voice);
  }

  // Check if TTS is available
  Future<bool> isLanguageAvailable(String language) async {
    if (!_isInitialized) await initialize();
    final result = await _flutterTts.isLanguageAvailable(language);
    if (result is bool) {
      return result;
    }
    return false;
  }

  // Get current settings
  double get speechRate => _speechRate;
  double get speechVolume => _speechVolume;
  double get speechPitch => _speechPitch;
  String get language => _language;
  bool get isInitialized => _isInitialized;

  // Speak word with pronunciation guide
  Future<void> speakWordWithPronunciation(
    String word,
    String pronunciation, {
    String language = 'ar-SA',
    bool speakPronunciation = true,
  }) async {
    // First speak the word
    await speak(word, language: language);

    // Wait a bit
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Then speak the pronunciation if requested
    if (speakPronunciation && pronunciation.isNotEmpty) {
      await speak(pronunciation, language: language);
    }
  }

  // Speak sentence slowly for learning
  Future<void> speakSlowly(String text, {String? language}) async {
    final originalRate = _speechRate;

    // Set slower rate
    await setSpeechRate(0.3);

    // Speak the text
    await speak(text, language: language);

    // Restore original rate
    await setSpeechRate(originalRate);
  }

  // Spell out word letter by letter
  Future<void> spellWord(String word, {String language = 'ar-SA'}) async {
    for (int i = 0; i < word.length; i++) {
      await speak(word[i], language: language);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }

  // Repeat text multiple times
  Future<void> repeatText(
    String text, {
    int times = 3,
    Duration delay = const Duration(milliseconds: 1000),
    String? language,
  }) async {
    for (int i = 0; i < times; i++) {
      await speak(text, language: language);
      if (i < times - 1) {
        await Future<void>.delayed(delay);
      }
    }
  }

  // Get supported languages for the app
  Map<String, String> getSupportedLanguages() {
    return {
      'ar-SA': 'Arabic (Saudi Arabia)',
      'ar-EG': 'Arabic (Egypt)',
      'ar-AE': 'Arabic (UAE)',
      'en-US': 'English (US)',
      'en-GB': 'English (UK)',
      'en-AU': 'English (Australia)',
    };
  }

  // Set language by code
  Future<void> setLanguageByCode(String languageCode) async {
    String ttsLanguage;

    switch (languageCode) {
      case 'ar':
        ttsLanguage = 'ar-SA';
        break;
      case 'en':
        ttsLanguage = 'en-US';
        break;
      default:
        ttsLanguage = 'ar-SA';
    }

    await setLanguage(ttsLanguage);
  }

  // Dispose resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _flutterTts.stop();
    }
  }

  // Test TTS functionality
  Future<void> testTTS() async {
    await speakArabic('مرحبا، هذا اختبار للنطق العربي');
    await Future<void>.delayed(const Duration(seconds: 2));
    await speakEnglish('Hello, this is a test for English pronunciation');
  }
}
