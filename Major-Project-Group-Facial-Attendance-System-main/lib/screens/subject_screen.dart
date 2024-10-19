import 'package:flutter/material.dart';
import 'attendance_screen.dart';

class SubjectScreen extends StatelessWidget {
  final String className;

  SubjectScreen({super.key, required this.className});

  final Map<String, List<String>> classSubjects = {
    'Class A': ['ML', 'BDA', 'NLP'],
    'Class B': ['DBMS', 'AI', 'OS'],
    'Class C': ['Networking', 'Security', 'HCI'],
  };

  @override
  Widget build(BuildContext context) {
    final subjects = classSubjects[className] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('Select Subject')),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text(subjects[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceScreen(
                      className: className,
                      subjectName: subjects[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
