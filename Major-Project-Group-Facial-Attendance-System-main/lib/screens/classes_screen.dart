import 'package:flutter/material.dart';
import 'subject_screen.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> classes = ['Class A', 'Class B', 'Class C'];

    return Scaffold(
      appBar: AppBar(title: Text('Select Class')),
      body: ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              leading: Icon(Icons.class_),
              title: Text(classes[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubjectScreen(
                          className: classes[index])),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
