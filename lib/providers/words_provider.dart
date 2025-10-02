import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word_model.dart';

// Mock provider for words
final wordActionsProvider = Provider<WordActions>((ref) {
  return WordActions();
});

class WordActions {
  Future<List<WordModel>> getWordsForGame(String gameType, {int count = 8}) async {
    // Mock words for testing
    return [
      WordModel(
        id: '1',
        wordEn: 'cat',
        wordAr: 'قطة',
        meaning: 'حيوان أليف',
        category: 'animals',
      ),
      WordModel(
        id: '2',
        wordEn: 'book',
        wordAr: 'كتاب',
        meaning: 'للقراءة',
        category: 'objects',
      ),
      WordModel(
        id: '3',
        wordEn: 'house',
        wordAr: 'بيت',
        meaning: 'مكان للسكن',
        category: 'places',
      ),
      WordModel(
        id: '4',
        wordEn: 'car',
        wordAr: 'سيارة',
        meaning: 'وسيلة نقل',
        category: 'transport',
      ),
      WordModel(
        id: '5',
        wordEn: 'tree',
        wordAr: 'شجرة',
        meaning: 'نبات كبير',
        category: 'nature',
      ),
    ];
  }
}
