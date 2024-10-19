import 'package:flutter/material.dart';
import 'Semesters.dart';

class HomeScreen extends StatelessWidget {
  final String professorName;

  const HomeScreen({super.key, required this.professorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $professorName', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SemestersScreen()),
                );
              },
              child: const Text('Mark Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
