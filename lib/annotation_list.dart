import 'dart:io';
import 'package:flutter/material.dart';
import 'annotation_manager.dart';
import 'pdf_viewer.dart';

class AnnotationsListPage extends StatefulWidget {
  @override
  _AnnotationsListPageState createState() => _AnnotationsListPageState();
}

class _AnnotationsListPageState extends State<AnnotationsListPage> with RouteAware {
  final AnnotationManager annotationManager = AnnotationManager();
  late List<Annotation> annotations;

  @override
  void initState() {
    super.initState();
    _loadAnnotations();
  }

  void _loadAnnotations() {
    setState(() {
      annotations = annotationManager.getAllAnnotations();
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
      body: ListView.builder(
        itemCount: annotations.length,
        itemBuilder: (context, index) {
          final annotation = annotations[index];
          return ListTile(
            title: Text('Page ${annotation.pageIndex + 1}: ${annotation.content}'),
            onTap: () {
              final directory = Directory(annotation.documentPath);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerPage(
                    directory: directory,
                    initialPage: annotation.pageIndex,
                  ),
                ),
              ).then((_) => _loadAnnotations());
            },
          );
        },
      ),
    );
  }
}
