import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class AttendanceProvider extends ChangeNotifier {
  Map<String, bool> _attendance = {};

  // Initialize the attendance list for each student.
  void initializeAttendance(List<String> studentRollNumbers) {
    _attendance = {for (var rollNo in studentRollNumbers) rollNo: false};
    notifyListeners();
  }

  // Get the current attendance map.
  Map<String, bool> getAttendance() {
    return _attendance;
  }

  // Set attendance for a specific student.
  void setAttendance(String rollNo, bool isPresent) {
    _attendance[rollNo] = isPresent;
    notifyListeners();
  }

  // Function to download attendance as a CSV file.
  Future<void> downloadAttendance(
      String className,
      String subjectName,
      String formattedDate,
      ) async {
    // Convert attendance map to CSV format.
    List<List<String>> rows = [
      ['Roll Number', 'Present/Absent'],
      ..._attendance.entries.map((entry) =>
      [entry.key, entry.value ? 'Present' : 'Absent']),
    ];

    // Generate the CSV content.
    String csvData = const ListToCsvConverter().convert(rows);

    // Get the directory to save the file.
    Directory? directory = await getExternalStorageDirectory();
    String path = '${directory?.path}/Attendance_${className}_$subjectName.csv';


    // Write CSV data to a file.
    File file = File(path);
    await file.writeAsString(csvData);

    print('Attendance saved to: $path');
    }
}
