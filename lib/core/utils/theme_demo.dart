// Demo page to test the new theme
import 'package:flutter/material.dart';

import 'theme_app.dart';

class ThemeDemoScreen extends StatefulWidget {
  const ThemeDemoScreen({super.key});

  @override
  State<ThemeDemoScreen> createState() => _ThemeDemoScreenState();
}

class _ThemeDemoScreenState extends State<ThemeDemoScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('اختبار الثيم الجديد'),
          actions: [
            Switch(
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colors Section
              _buildSection(context, 'الألوان الأساسية', [
                _colorTile(
                  context,
                  'Primary',
                  Theme.of(context).colorScheme.primary,
                ),
                _colorTile(
                  context,
                  'Secondary',
                  Theme.of(context).colorScheme.secondary,
                ),
                _colorTile(
                  context,
                  'Tertiary',
                  Theme.of(context).colorScheme.tertiary,
                ),
                _colorTile(
                  context,
                  'Success',
                  AppTheme.getSuccessColor(context),
                ),
                _colorTile(
                  context,
                  'Warning',
                  AppTheme.getWarningColor(context),
                ),
                _colorTile(context, 'Info', AppTheme.getInfoColor(context)),
              ]),

              const SizedBox(height: 24),

              // Typography Section
              _buildSection(context, 'الطباعة والخطوط', [
                Text(
                  'Display Large',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  'Display Medium',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text(
                  'Display Small',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  'Headline Large',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  'Headline Medium',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Title Large',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Title Medium',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Body Large',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Body Medium',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Label Large',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ]),

              const SizedBox(height: 24),

              // Buttons Section
              _buildSection(context, 'الأزرار', [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('زر مرفوع'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('زر محدد'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('زر نص'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('زر معبأ'),
                      ),
                    ),
                  ],
                ),
              ]),

              const SizedBox(height: 24),

              // Cards Section
              _buildSection(context, 'البطاقات والحاويات', [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بطاقة تجريبية',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'هذه بطاقة تجريبية لاختبار الثيم الجديد. يجب أن تبدو جيدة في كلا الوضعين الفاتح والمظلم.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'نقاط: 150',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: AppTheme.getSuccessColor(context),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              // Input Fields Section
              _buildSection(context, 'حقول الإدخال', [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'اسم المستخدم',
                    hintText: 'أدخل اسم المستخدم',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    hintText: 'أدخل كلمة المرور',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility),
                  ),
                  obscureText: true,
                ),
              ]),

              const SizedBox(height: 24),

              // Game Elements Section
              _buildSection(context, 'عناصر الألعاب', [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تعلم الكلمات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ابدأ رحلة التعلم الممتعة',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('الثيم يعمل بشكل ممتاز! 🎉'),
                backgroundColor: AppTheme.getSuccessColor(context),
              ),
            );
          },
          icon: const Icon(Icons.check),
          label: const Text('اختبار'),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _colorTile(BuildContext context, String name, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
