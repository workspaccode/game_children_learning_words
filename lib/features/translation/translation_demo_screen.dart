import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../providers/translation_provider.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/translation_widget.dart';

class TranslationDemoScreen extends ConsumerStatefulWidget {
  const TranslationDemoScreen({super.key});

  @override
  ConsumerState<TranslationDemoScreen> createState() =>
      _TranslationDemoScreenState();
}

class _TranslationDemoScreenState extends ConsumerState<TranslationDemoScreen> {
  final TextEditingController _textController = TextEditingController();
  String _fromLanguage = 'en';
  String _toLanguage = 'ar';
  String? _translatedText;
  bool _isTranslating = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _translateText() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final result = await ref
          .read(translationProvider.notifier)
          .translateText(
            text: _textController.text,
            from: _fromLanguage,
            to: _toLanguage,
          );

      setState(() {
        _translatedText = result;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _translatedText = 'خطأ في الترجمة: $e';
        _isTranslating = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _fromLanguage;
      _fromLanguage = _toLanguage;
      _toLanguage = temp;
      _translatedText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(translationProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'مترجم النصوص', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // أمثلة على الـ Widgets
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أمثلة على استخدام الترجمة:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // مثال 1: ترجمة بسيطة
                    const Text('1. ترجمة بسيطة:'),
                    const SizedBox(height: 8),
                    const QuickTranslate(
                      text: 'Hello, how are you?',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // مثال 2: ترجمة تفاعلية
                    const Text('2. ترجمة تفاعلية (اضغط للترجمة):'),
                    const SizedBox(height: 8),
                    const InteractiveTranslationWidget(
                      text: 'Welcome to our learning app!',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // مثال 3: ترجمة مخصصة
                    const Text('3. ترجمة من الفرنسية:'),
                    const SizedBox(height: 8),
                    const TranslationWidget(
                      text: 'Bonjour, comment allez-vous?',
                      fromLanguage: 'fr',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // مترجم تفاعلي
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مترجم تفاعلي:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // اختيار اللغات
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _fromLanguage,
                            decoration: const InputDecoration(
                              labelText: 'من',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('English'),
                              ),
                              DropdownMenuItem(
                                value: 'ar',
                                child: Text('العربية'),
                              ),
                              DropdownMenuItem(
                                value: 'fr',
                                child: Text('Français'),
                              ),
                              DropdownMenuItem(
                                value: 'es',
                                child: Text('Español'),
                              ),
                              DropdownMenuItem(
                                value: 'de',
                                child: Text('Deutsch'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _fromLanguage = value!;
                                _translatedText = null;
                              });
                            },
                          ),
                        ),

                        IconButton(
                          onPressed: _swapLanguages,
                          icon: const Icon(Icons.swap_horiz),
                        ),

                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _toLanguage,
                            decoration: const InputDecoration(
                              labelText: 'إلى',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('English'),
                              ),
                              DropdownMenuItem(
                                value: 'ar',
                                child: Text('العربية'),
                              ),
                              DropdownMenuItem(
                                value: 'fr',
                                child: Text('Français'),
                              ),
                              DropdownMenuItem(
                                value: 'es',
                                child: Text('Español'),
                              ),
                              DropdownMenuItem(
                                value: 'de',
                                child: Text('Deutsch'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _toLanguage = value!;
                                _translatedText = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // حقل النص
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'النص المراد ترجمته',
                        border: OutlineInputBorder(),
                        hintText: 'اكتب النص هنا...',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _translatedText = null;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // زر الترجمة
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isTranslating ? null : _translateText,
                        child: _isTranslating
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('جاري الترجمة...'),
                                ],
                              )
                            : const Text('ترجم'),
                      ),
                    ),

                    // النتيجة
                    if (_translatedText != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          _translatedText!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // معلومات الحالة
            if (translationState.error != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'خطأ: ${translationState.error}',
                  style: TextStyle(color: Colors.red[800]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
