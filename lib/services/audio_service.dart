import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'permission_service.dart';

class AudioService extends ChangeNotifier {
  AudioService() {
    _initializeTts();
    _initializeSpeechToText();
  }
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SpeechToText _speechToText = SpeechToText();
  final PermissionService _permissionService = PermissionService();

  bool _isSpeaking = false;
  bool _isPlaying = false;
  bool _isListening = false;
  bool _speechEnabled = false;
  String _recognizedWords = '';
  double _speechVolume = 0;
  String? _errorMessage;

  // Getters
  bool get isSpeaking => _isSpeaking;
  bool get isPlaying => _isPlaying;
  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;
  String get recognizedWords => _recognizedWords;
  double get speechVolume => _speechVolume;
  String? get errorMessage => _errorMessage;

  // Initialize Text-to-Speech
  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('ar-SA'); // Default to Arabic
      await _flutterTts.setSpeechRate(0.5); // Slower for children
      await _flutterTts.setVolume(1);
      await _flutterTts.setPitch(1.2); // Higher pitch for children

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        _errorMessage = 'خطأ في النطق: $msg';
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'فشل في تهيئة خدمة النطق';
      notifyListeners();
    }
  }

  // Initialize Speech-to-Text
  Future<void> _initializeSpeechToText() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          _errorMessage = 'خطأ في التعرف على الصوت: ${error.errorMsg}';
          _isListening = false;
          notifyListeners();
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
      notifyListeners();
    } catch (e) {
      _speechEnabled = false;
      _errorMessage = 'فشل في تهيئة خدمة التعرف على الصوت';
      notifyListeners();
    }
  }

  // Text-to-Speech Methods
  Future<void> speak(String text, {String? language}) async {
    try {
      if (_isSpeaking) {
        await stop();
      }

      if (language != null) {
        await _flutterTts.setLanguage(language);
      }

      await _flutterTts.speak(text);
    } catch (e) {
      _errorMessage = 'فشل في نطق النص';
      notifyListeners();
    }
  }

  Future<void> speakArabic(String text) async {
    await speak(text, language: 'ar-SA');
  }

  Future<void> speakEnglish(String text) async {
    await speak(text, language: 'en-US');
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل في إيقاف النطق';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل في إيقاف النطق مؤقتاً';
      notifyListeners();
    }
  }

  // Audio Player Methods
  Future<void> playSound(String soundPath) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.play(AssetSource(soundPath));
      _isPlaying = true;
      notifyListeners();

      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'فشل في تشغيل الصوت';
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> playNetworkSound(String url) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.play(UrlSource(url));
      _isPlaying = true;
      notifyListeners();

      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'فشل في تشغيل الصوت';
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل في إيقاف الصوت';
      notifyListeners();
    }
  }

  // Speech Recognition Methods
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> startListening({String? language, BuildContext? context}) async {
    try {
      if (!_speechEnabled) {
        await _initializeSpeechToText();
      }

      if (!_speechEnabled) {
        _errorMessage = 'خدمة التعرف على الصوت غير متاحة';
        notifyListeners();
        return;
      }

      // التحقق من الصلاحية باستخدام PermissionService
      bool hasPermission;
      if (context != null) {
        hasPermission = await _permissionService.requestMicrophoneWithDialog(
          context,
        );
      } else {
        hasPermission = await _permissionService.requestMicrophonePermission();
      }

      if (!hasPermission) {
        _errorMessage = 'يجب السماح بالوصول للميكروفون لاستخدام هذه الميزة';
        notifyListeners();
        return;
      }

      _recognizedWords = '';
      _isListening = true;
      notifyListeners();

      await _speechToText.listen(
        onResult: (result) {
          _recognizedWords = result.recognizedWords;
          _speechVolume = result.hasConfidenceRating ? result.confidence : 0.0;
          notifyListeners();
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        localeId: language ?? 'ar-SA',
        onSoundLevelChange: (level) {
          _speechVolume = level;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'فشل في بدء الاستماع';
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل في إيقاف الاستماع';
      notifyListeners();
    }
  }

  // TTS Settings
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      _errorMessage = 'فشل في تغيير سرعة النطق';
      notifyListeners();
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
    } catch (e) {
      _errorMessage = 'فشل في تغيير نبرة الصوت';
      notifyListeners();
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
    } catch (e) {
      _errorMessage = 'فشل في تغيير مستوى الصوت';
      notifyListeners();
    }
  }

  // Background Music Methods
  Future<void> playBackgroundMusic() async {
    // Implementation for background music
  }

  Future<void> stopBackgroundMusic() async {
    // Implementation for stopping background music
  }

  Future<void> pauseBackgroundMusic() async {
    // Implementation for pausing background music
  }

  Future<void> resumeBackgroundMusic() async {
    // Implementation for resuming background music
  }

  Future<void> setMusicVolume(double volume) async {
    // Implementation for setting music volume
  }

  Future<void> setMute(bool mute) async {
    // Implementation for muting/unmuting
  }

  Future<void> stopSpeaking() async {
    await stop();
  }

  Future<void> setSpeechPitch(double pitch) async {
    await setPitch(pitch);
  }

  Future<void> setSpeechVolume(double volume) async {
    await setVolume(volume);
  }

  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
    } catch (e) {
      _errorMessage = 'فشل في تغيير اللغة';
      notifyListeners();
    }
  }

  // Utility Methods
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      if (languages is List) {
        return languages.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        return voices
            .map((voice) => (voice as Map<String, dynamic>)['name'] as String)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Pronunciation Scoring
  double calculatePronunciationScore(String expected, String actual) {
    if (expected.isEmpty || actual.isEmpty) return 0;

    expected = expected.toLowerCase().trim();
    actual = actual.toLowerCase().trim();

    if (expected == actual) return 100;

    // Simple similarity calculation
    final expectedWords = expected.split(' ');
    final actualWords = actual.split(' ');

    int matches = 0;
    int totalWords = expectedWords.length;

    for (final expectedWord in expectedWords) {
      for (final actualWord in actualWords) {
        if (_calculateWordSimilarity(expectedWord, actualWord) > 0.7) {
          matches++;
          break;
        }
      }
    }

    return (matches / totalWords) * 100;
  }

  double _calculateWordSimilarity(String word1, String word2) {
    if (word1 == word2) return 1;

    final len1 = word1.length;
    final len2 = word2.length;
    final maxLen = len1 > len2 ? len1 : len2;

    if (maxLen == 0) return 1;

    return (maxLen - _levenshteinDistance(word1, word2)) / maxLen;
  }

  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
    _speechToText.stop();
    super.dispose();
  }
}
