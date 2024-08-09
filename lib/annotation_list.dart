import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plangrid/utils/helpers.dart';
import 'models/annotation_manager.dart';
import 'pdf_viewer.dart';

class AnnotationsListPage extends StatefulWidget {
  @override
  _AnnotationsListPageState createState() => _AnnotationsListPageState();
}

class _AnnotationsListPageState extends State<AnnotationsListPage> with RouteAware {
  final AnnotationManager annotationManager = AnnotationManager();
  late List<Annotation> annotations;
  String? selectedPdf;
  int? selectedPage;
  List<File> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }

  void _loadPdfFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(directory.path);
    final directories = pdfDir.listSync().whereType<Directory>().toList();
    setState(() {
      pdfFiles = directories.map((file) => File(file.path)).toList();
      if (pdfFiles.isNotEmpty) {
        selectedPdf = pdfFiles.first.path; // Set initial selected PDF
        _loadAnnotations();
      }
    });
  }

  void _loadAnnotations() {
    setState(() {
      annotations = [];
      if (selectedPdf != null && selectedPage != null) {
        final annotationKey = getAnnotationKey(selectedPdf!, (selectedPage! - 1));
        print(annotationKey);
        annotations = annotationManager.getAnnotations(annotationKey) ?? [];
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      _loadAnnotations();
      return true;
    });
  }

  @override
  void dispose() {
    ModalRoute.of(context)?.removeScopedWillPopCallback(() async {
      _loadAnnotations();
      return true;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annotations List'),
      ),
      body: Column(
        children: [
          // Dropdown for selecting PDF file
          DropdownButton<String>(
            hint: const Text('Select PDF'),
            value: selectedPdf,
            items: pdfFiles.map((File pdf) {
              return DropdownMenuItem<String>(
                value: pdf.path,
                child: Text(pdf.path.split('/').last),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedPdf = newValue;
                selectedPage = null; // Reset selected page
                _loadAnnotations(); // Load annotations for the new PDF
              });
            },
          ),
          // Dropdown for selecting page
          if (selectedPdf != null)
            DropdownButton<int>(
              hint: const Text('Select Page'),
              value: selectedPage,
              items: List.generate(annotationManager.getAnnotations(getAnnotationKey(selectedPdf!, 0)).length ?? 0, (index) => index + 1)
                  .map((int page) {
                return DropdownMenuItem<int>(
                  value: page,
                  child: Text('Page $page'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  selectedPage = newValue;
                  _loadAnnotations(); // Load annotations for the new page
                });
              },
            ),
          // List of annotations grouped by rooms
          if (selectedPdf != null && selectedPage != null)
            Expanded(
              child: ListView.builder(
                itemCount: annotations.length,
                itemBuilder: (context, index) {
                  final roomAnnotations = annotations.where((annotation) => annotation.content.room == annotations[index].content.room).toList();
                  return ExpansionTile(
                    title: Text(annotations[index].content.room),
                    children: roomAnnotations.map((annotation) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                        child: ListTile(
                          title: Text(annotation.content.toString()),
                          onTap: () {
                            final directory = Directory(selectedPdf!);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfViewerPage(
                                  directory: directory,
                                  initialPage: selectedPage! - 1,
                                ),
                              ),
                            ).then((_) => _loadAnnotations());
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
