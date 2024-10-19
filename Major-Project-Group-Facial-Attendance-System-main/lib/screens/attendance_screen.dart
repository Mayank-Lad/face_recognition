  import 'package:flutter/material.dart';
  import 'dart:convert';
  import 'dart:io';
  import 'package:http/http.dart' as http;
  import 'package:image_picker/image_picker.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:csv/csv.dart';
  
  class AttendanceScreen extends StatefulWidget {
    final String className;
    final String subjectName;
  
    const AttendanceScreen({
      Key? key,
      required this.className,
      required this.subjectName,
    }) : super(key: key);
  
    @override
    _AttendanceScreenState createState() => _AttendanceScreenState();
  }
  
  class _AttendanceScreenState extends State<AttendanceScreen> {
    List<String> recognizedStudents = [];
    Map<String, bool> attendanceStatus = {};
    List<String> allStudents = [
      'Mayank', 'Sahil', 'Sarthak', 'Rohan','Omkar','Atharva','Chinmay','Harish','Atharva_Ingole','Aarav', 'Ishaan', 'Neha', 'Riya',
      'Ananya', 'Kavya', 'Aditya', 'Priya', 'Vivek', 'Sneha', 'Tanvi', 'Raghav',
      'Arjun', 'Simran', 'Yash', 'Dhruv', 'Naina', 'Arnav', 'Ritika', 'Manav',
    ]; // Add more names as needed
  
    bool _isLoading = false;
    final ImagePicker _picker = ImagePicker();
    File? _selectedImage;
  
    @override
    void initState() {
      super.initState();
      _requestStoragePermission();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showImageSourceDialog();
      });
    }
  
    Future<void> _requestStoragePermission() async {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        await openAppSettings();
      }
    }
  
    Future<void> _showImageSourceDialog() async {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          );
        },
      );
    }
  
    Future<void> _pickImage(ImageSource source) async {
      final pickedFile = await _picker.pickImage(source: source);
  
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
  
        print('Image selected: ${_selectedImage?.path}');
        await _uploadImageToServer();
      } else {
        print('No image selected.');
      }
    }
  
    Future<void> _uploadImageToServer() async {
      if (_selectedImage == null) return;
  
      setState(() {
        _isLoading = true;
      });
  
      final String serverUrl = 'http://192.168.1.3:5000/recognize';
  
      final request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      ));
  
      try {
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
  
        if (response.statusCode == 200) {
          if (data.containsKey('recognized_students')) {
            setState(() {
              recognizedStudents = List<String>.from(data['recognized_students']);
              _initializeAttendanceStatus();
            });
            _showSnackbar(data['message'] ?? "Recognition successful", Colors.green);
          } else {
            print('No recognized students found in response.');
            _showSnackbar("No recognized students found.", Colors.red);
          }
        } else {
          print('Failed to process image: ${data['error']}');
          _showSnackbar("Failed to process image: ${data['error']}", Colors.red);
        }
      } catch (error) {
        print('Error uploading image: $error');
        _showSnackbar("Error uploading image: $error", Colors.red);
      }
  
      setState(() {
        _isLoading = false;
      });
    }
  
    void _initializeAttendanceStatus() {
      for (var student in allStudents) {
        attendanceStatus[student] = recognizedStudents.contains(student);
      }
    }
  
    void _toggleAttendance(String student) {
      setState(() {
        attendanceStatus[student] = !(attendanceStatus[student] ?? false);
      });
    }
  
    void _showSnackbar(String message, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: Duration(seconds: 3),
        ),
      );
    }
  
    Future<int?> _getLectureHours() async {
      int? lectureHours;
      await showDialog<int>(
        context: context,
        builder: (context) {
          final TextEditingController _controller = TextEditingController();
          return AlertDialog(
            title: Text('Enter Lecture Hours'),
            content: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: "Lecture Hours"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  lectureHours = int.tryParse(_controller.text);
                  if (lectureHours != null) {
                    Navigator.of(context).pop();
                  } else {
                    _showSnackbar("Please enter a valid number.", Colors.red);
                  }
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return lectureHours;
    }
  
    Future<void> _downloadAttendance() async {
      int? lectureHours = await _getLectureHours();
      if (lectureHours == null) {
        _showSnackbar("Lecture hours input was canceled.", Colors.red);
        return;
      }
  
      List<List<String>> rows = [
        ['Student Name', 'Timestamp'],
        ...attendanceStatus.entries.map((entry) =>
        [entry.key, entry.value ? lectureHours.toString() : '0']),
      ];
  
      String csvData = const ListToCsvConverter().convert(rows);
  
      try {
        Directory? directory = await getExternalStorageDirectory();
        String path = '${directory?.path}/Attendance_${widget.className}_${widget.subjectName}.csv';
  
        File file = File(path);
        await file.writeAsString(csvData);
  
        _showSnackbar("Attendance saved to: $path", Colors.green);
        print('Attendance saved to: $path');
      } catch (e) {
        _showSnackbar("Error saving attendance: $e", Colors.red);
        print('Error saving attendance: $e');
      }
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Attendance Management"),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Recognized Students",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: allStudents.length,
                  itemBuilder: (context, index) {
                    final student = allStudents[index];
                    return ListTile(
                      title: Text(student),
                      trailing: Switch(
                        value: attendanceStatus[student] ?? false,
                        onChanged: (value) => _toggleAttendance(student),
                      ),
                    );
                  },
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showImageSourceDialog,
                child: Text("Take New Attendance"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _downloadAttendance,
                child: Text("Download Attendance"),
              ),
              if (_selectedImage != null) ...[
                SizedBox(height: 20),
                Image.file(_selectedImage!, height: 200),
              ],
            ],
          ),
        ),
      );
    }
  }
