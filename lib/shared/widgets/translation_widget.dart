import 'package:flutter/material.dart';

class TranslationWidget extends StatefulWidget {
  const TranslationWidget({
    super.key,
    required this.text,
    this.fromLanguage = 'auto',
    this.toLanguage = 'ar',
    this.style,
    this.loadingWidget,
    this.showOriginalOnError = true,
  });
  final String text;
  final String fromLanguage;
  final String toLanguage;
  final TextStyle? style;
  final Widget? loadingWidget;
  final bool showOriginalOnError;

  @override
  State<TranslationWidget> createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
  String? translatedText;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _translateText();
  }

  @override
  void didUpdateWidget(TranslationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.fromLanguage != widget.fromLanguage ||
        oldWidget.toLanguage != widget.toLanguage) {
      _translateText();
    }
  }

  Future<void> _translateText() async {
    if (widget.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    // التحقق من وجود ترجمة في الكاش
    // final cachedTranslation = ref
    //     .read(translationProvider.notifier)
    //     .getCachedTranslation(
    //       widget.text,
    //       widget.fromLanguage,
    //       widget.toLanguage,
    //     );

    // if (cachedTranslation != null) {
    //   setState(() {
    //     translatedText = cachedTranslation;
    //     isLoading = false;
    //   });
    //   return;
    // }

    // ترجمة النص
    //     try {
    //       final result = await ref
    //           .read(translationProvider.notifier)
    //           .translateText(
    //             text: widget.text,
    //             from: widget.fromLanguage,
    //             to: widget.toLanguage,
    //           );

    //       if (mounted) {
    //         setState(() {
    //           translatedText = result;
    //           isLoading = false;
    //         });
    //       }
    //     } catch (e) {
    //       if (mounted) {
    //         setState(() {
    //           translatedText = widget.showOriginalOnError
    //               ? widget.text
    //               : 'Translation Error';
    //           isLoading = false;
    //         });
    //       }
    //     }
      }

      @override
      Widget build(BuildContext context) {
        if (isLoading) {
          return widget.loadingWidget ??
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
        }

        return Text(translatedText ?? widget.text, style: widget.style);
  }
}

// Widget مبسط للترجمة السريعة
abstract class QuickTranslate extends Widget {
  const QuickTranslate({super.key, required this.text, this.style});
  final String text;
  final TextStyle? style;

  Widget build(BuildContext context) {
    return TranslationWidget(text: text, fromLanguage: 'en', style: style);
  }
  
 
}

// Widget للترجمة التفاعلية مع إمكانية التبديل
class InteractiveTranslationWidget extends StatefulWidget {
  const InteractiveTranslationWidget({
    super.key,
    required this.text,
    this.style,
  });
  final String text;
  final TextStyle? style;

  @override
  State<InteractiveTranslationWidget> createState() =>
      _InteractiveTranslationWidgetState();
}

class _InteractiveTranslationWidgetState
    extends State<InteractiveTranslationWidget> {
  bool showTranslation = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showTranslation = !showTranslation;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.text, style: widget.style),
            if (showTranslation) ...[
              const SizedBox(height: 8),
              const Divider(),
              TranslationWidget(
                text: widget.text,
                fromLanguage: 'en',
                style: widget.style?.copyWith(
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              showTranslation ? 'اضغط لإخفاء الترجمة' : 'اضغط لعرض الترجمة',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
