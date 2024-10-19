import 'package:flutter/material.dart';
import 'classes_screen.dart';

class SemestersScreen extends StatelessWidget {
  const SemestersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> semesters = [
      'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
      'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Select Semester')),
      body: ListView.builder(
        itemCount: semesters.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              leading: Icon(Icons.school),
              title: Text(semesters[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassesScreen()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
