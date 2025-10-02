import 'package:flutter/material.dart';

class SentenceBuildingGameScreen extends StatelessWidget {
  const SentenceBuildingGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentence Building Game'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Sentence Building Game',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Build sentences from words',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
