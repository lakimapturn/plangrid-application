import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:plangrid/models/room_manager.dart';
import 'package:plangrid/utils/helpers.dart';

class PdfUploadPage extends StatefulWidget {
  @override
  _PdfUploadPageState createState() => _PdfUploadPageState();
}

class _PdfUploadPageState extends State<PdfUploadPage> {
  bool _isLoading = false;
  final gemini = Gemini.instance;
  RoomManager roomManager = RoomManager();

  Future<void> _pickAndConvertPdf() async {
    // Pick a PDF file
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

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
      final pngBytes = (await image.toByteData(format: ImageByteFormat.png))!
          .buffer
          .asUint8List();

      final filePath = '${pdfDir.path}/page_$i.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      String key = getRoomKey(pdfDir.path, i - 1);
      await _analyzeImage(filePath, key);
    }

    await pdfDocument.dispose();
  }

  Future<void> _analyzeImage(String imagePath, String key) async {
    try {
      final file = File(imagePath);
      final result = await gemini.textAndImage(
        text: "Extract room names from the image. "
            "Ensure that the output is JSON format (should look something like this: {rooms: []}).",
        images: [file.readAsBytesSync()],
      );

      final parts = result?.content?.parts ?? [];
      if (parts.isNotEmpty) {
        final rawJson = parts.first.text;
        final jsonString = _extractJsonString(rawJson!);
        final data = jsonDecode(jsonString);
        final rooms = data['rooms'] as List<dynamic>? ?? [];
        for (var room in rooms) {
          roomManager.addRoom(key, room.toString());
        }
        print(key);
        print('Extracted data: $data');
      }
    } catch (e) {
      print('Error analyzing image: $e');
    }
  }

  String _extractJsonString(String rawText) {
    final jsonStart = rawText.indexOf('{');
    final jsonEnd = rawText.lastIndexOf('}');
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      return rawText.substring(jsonStart, jsonEnd + 1);
    }
    return '{}';
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
