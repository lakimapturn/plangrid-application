import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'pdf_list.dart';
import 'pdf_upload.dart';
import 'annotation_list.dart';

void main() {
  Gemini.init(apiKey: 'AIzaSyCqz3SviaSrRO8eZC3K33Ub6-e2gjxeKSs');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Annotation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Annotation App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Upload PDF'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PdfUploadPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('View PDFs'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PdfListPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('View Annotations'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AnnotationsListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
