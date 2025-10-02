import 'package:flutter/material.dart';

class GoogleUserTypeScreen extends StatelessWidget {
  const GoogleUserTypeScreen({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User Type'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Google User Type Selection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Select your user type to continue',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
