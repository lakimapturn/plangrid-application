import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'pdf_viewer.dart';

class PdfListPage extends StatefulWidget {
  @override
  _PdfListPageState createState() => _PdfListPageState();
}

class _PdfListPageState extends State<PdfListPage> {
  List<Directory> _pdfDirectories = [];

  @override
  void initState() {
    super.initState();
    _loadPdfDirectories();
  }

  Future<void> _loadPdfDirectories() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(directory.path);
    final directories = pdfDir.listSync().whereType<Directory>().toList();
    setState(() {
      _pdfDirectories = directories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF List'),
      ),
      body: ListView.builder(
        itemCount: _pdfDirectories.length,
        itemBuilder: (context, index) {
          final pdfDir = _pdfDirectories[index];
          return ListTile(
            title: Text(path.basename(pdfDir.path)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerPage(directory: pdfDir),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
