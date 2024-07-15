import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:path/path.dart' as path;

class PdfUploadPage extends StatefulWidget {
  @override
  _PdfUploadPageState createState() => _PdfUploadPageState();
}

class _PdfUploadPageState extends State<PdfUploadPage> {
  bool _isLoading = false;

  Future<void> _pickAndConvertPdf() async {
    // Pick a PDF file
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isLoading = true;
      });

      final pdfPath = result.files.single.path!;
      await convertPdfToImages(pdfPath);

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> convertPdfToImages(String pdfPath) async {
    // Load the PDF file
    final pdfDocument = await PdfDocument.openFile(pdfPath);

    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Create a directory for the PDF
    final pdfFolderName = path.basenameWithoutExtension(pdfPath);
    final pdfDir = Directory('${directory.path}/$pdfFolderName');
    if (!pdfDir.existsSync()) {
      pdfDir.createSync();
    }

    // Convert each page to an image and save it in the directory
    for (int i = 1; i <= pdfDocument.pageCount; i++) {
      final page = await pdfDocument.getPage(i);
      final render = await page.render();
      final image = await render.createImageIfNotAvailable();
      final pngBytes = (await image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();

      final filePath = '${pdfDir.path}/page_$i.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

    }

    await pdfDocument.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload PDF'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: _pickAndConvertPdf,
          child: const Text('Upload PDF and Convert'),
        ),
      ),
    );
  }
}
